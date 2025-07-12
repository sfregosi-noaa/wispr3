% WORKFLOW_GENERATEPREAMPGAINCURVE.M
%	Generate a WISPR3 calibration gain curve from a sweep of known voltage
%
%	Description:
%		Example script to calculate and plot a WISPR3 preamplifier
%		calibration gain curve. A calibration recording file created with
%		a signal generator input directly to the WISPR3 and preamp board
%		(SEE DETAILED INSTRUCTIONS HERE)
%       is read in, a user selects a single calibration sweep, and the gain
%       is calculated, plotted, and saved as a .mat and .txt file.
%
%       The calibration input signal is a constant voltage frequency sweep
%       over the range of interest, typically from 0 to 200 kHz (the upper
%       limit of the sample rate) over at least 10 or 20 seconds. The
%       longer the sweep, the better. This is the input voltage (vin). The
%       recorded signal is the output voltage (vout) and is the output of
%       the preamp and adc; it includes all the preamp gain stages and the
%       filter including the high pass and low pass analog filters and the
%       digital anti-aliasing filters of the adc.
%
%       Gain is calculated as (vout) / (vin) expressed in dB for each
%       frequency bin over the range of interest. The calibrat
%
%       The output .txt file can be read by wispr or provided as input to
%       agate's generateWisprSystemSensitivity function to be combined with
%       system gain and hydrophone sensitivity to export overall system
%       sensitivity for calibrated sound analysis.
%
%	Notes
%       Modified from the preamp_cal.m script (c. jones 02/2025)found in
%       https://github.com/embeddedocean/wispr3. Modifications make it more
%       customizable and output the results in a format to feed into
%       netCDF/csv creation using agate's generateWisprSystemSensitivity
%       function to provide full system calibration info.
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:   2025 July 08
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% User modified inputs

% SN of the preamp/adc board - must be a string less than 16 chars
% used for filename generation
sn = 'WISPR3_no2';

% fullfile path of calibration recording (as raw .dat file)
% set to [] to be prompted to select one
data_file = [];
data_file = "D:\wispr_calibration\wispr_no2\250514\WISPR_250514_213247.dat";

% define hydropgone sensitivity, not used for the calibration
% but saved in the calibration file for use later
hydro_sens = -165;

% define the amplitude of sine wave sweep (in volts)
% ideally 10 mV)
amp = 0.010;

% was a 20 dB attenuator used?
attenuator = true;

%% Check inputs

% check serial number (this is used for file name generation)
if ~exist('sn', 'var') || isempty(sn)
    % prompt for SN
    sn = 'XXXX'; % as example
    str = sprintf('Enter SN [%s]: ', sn);
    in = input(str, 's');
    if(~isempty(in))
        sn = in;
    end
end

% pick a data file for the data recorded using the signal generator
if ~exist('data_file', 'var') || ~exist(data_file, 'file')
    [file, dpath, filterindex] = uigetfile('*.dat', 'Pick a data file');
    data_file = fullfile(dpath, file);
    fprintf('Selected calibration recording file %s\n', file);
end

if ~exist('hydro_sens', 'var') || isempty(hydro_sens)
    % prompt for hydrophone sensitivity
    hydro_sens = 0;
    str = sprintf('Enter hydrophone sensitivity [%s]: ', hydro_sens);
    in = input(str, 's');
    if(~isempty(in))
        hydro_sens= in;
    end
end

% define the amplitude of sine wave sweep
if ~exist('amp', 'var') || isempty(amp)
    amp = 0;
    str = sprintf('Enter input amplitude in volts [%f]: ', amp);
    in =  input(str);
    if(~isempty(in))
        amp = in;
    end
end

% Define input voltage if a 20db attenuator (20 dB)
% The 2 is because amp half of the differenceial signal
% Need to check that the attenuator 20db include the rms factor of sqrt(2)/2
if attenuator == true
    vin = 2 * amp / 10;
else
    vin = amp;
end

%% set up output filenames

% define name of output gain files
mat_file = sprintf('%s_preamp_gain.mat', sn);
txt_file = sprintf('%s_preamp_gain.txt', sn);
png_file = sprintf('%s_preamp_gain.png', sn);


%% do stuff

% Read the calibration data file collected with a signal generator input
[hdr, vout, time] = read_wispr_file(name, 2, 1024);

%vout = sqrt(mean(data(:).^2)); % RMS
vout = vout(:);

% plot data buffers
figure(1); clf;
d = 50;
%plot(time(1:d:end,:), vout(1:d:end,:),'.-');
plot(vout(1:d:end),'-');
ylabel('Volts');
xlabel('Sample');
grid on;
%axis([min(min(time)) max(max(time)) -5.1 5.1]);

% pick a segment of the input data to use for calibration
% This should be at a minimul one complete sweep pulse
bound = ginput(2);
start = floor(d * bound(1));
stop = floor(d * bound(2)) + 1;
vout = vout(start:stop);

figure(1); %clf;
plot(vout,'.-');
ylabel('Volts');
xlabel('Sample');
grid on;
%axis([min(min(time)) max(max(time)) -5.1 5.1]);

% Calc spectrum of vout/vin
fft_size = 256;
overlap = fft_size-64;
%window = rectwin(fft_size);
window = hamming(fft_size)*1.59; %multiply energy correction
%window = hann(fft_size)*1.63;
fs = hdr.sampling_rate;
[spec, f] = cal_spec(vout/vin, fs, window, overlap, time(1));

preamp_gain = 10*log10(spec);
preamp_freq = f;

% plot spectrum
fig2 = figure(2); clf;
set(fig2, 'Position', [50 50 950 450]);
hold on;
plot(preamp_freq/1000, preamp_gain,'.-'); %normalize the power spec
grid(gca,'minor');
grid on;
xlabel('Frequency [kHz]'),
ylabel('20*log_{10}( V_{out} \\ V_{in} )');
%axis([0 f(end)/1000 -185 -135]);
title(sn);

% save the plot
print(fig2, '-dpng', png_file);

%save the data as mat file
save(mat_file, 'vout', 'vin', 'fs', 'preamp_freq', 'preamp_gain');

nbins = length(preamp_freq);

fp = fopen(txt_file, 'w');
fprintf(fp, 'PREAMP GAIN\r\n');
fprintf(fp, 'SN: %s\r\n', sn);
fprintf(fp, 'sensitivity: %.2f\r\n', hydro_sens);
fprintf(fp, 'nbins: %d\r\n', nbins);
fprintf(fp, 'dfreq: %.3f\r\n', preamp_freq(3) - preamp_freq(2));
for n=1:nbins
    fprintf(fp, '%.2f, %.2f\n', preamp_freq(n), preamp_gain(n));
end
fclose(fp);



