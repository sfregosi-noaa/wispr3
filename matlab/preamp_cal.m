%
% matlab script to plot wispr pre-amp calibration gain curve
% Data files names indicate the freq and amplitude in mvolts (v_sig) of the input sine wave
% generated with signal generator and attenuated with a -20 db voltage
% divider with R2 = 47 and R1 = 4.7k (v_in = v_sig * R2/(R1+R2))
% The effective source impedence is R2*R2/(R1+R2)

clear all;

% SN must be a string
sn = 'EOS01';

% number of buffer to concatenate and plot
str = sprintf('Enter SN [%s]: ', sn);
in = input(str, 's');
if(~isempty(in))
    sn = in;
end

mat_file = sprintf('%s_preamp_gain.mat', sn);
txt_file = sprintf('%s_preamp_gain.txt', sn);

%dpath = 'C:\Users\chris\Documents\Hefring\Glider\PAM\wispr3\bench_tests\bench_tests_12_2_21\preamp_cal';

%file = dir([dpath '\*.dat']);

[file, dpath, filterindex] = uigetfile('*.dat', 'Pick a data file');
name = fullfile(dpath,file);

voltage_divider = 101; % 

nfiles = length(file);

hydro_sens = -176.0;

% voltage divider for input
R2 = 47;
R1 = 4700;

amp = 0.010; % amplitude of sine wave input to voltage divider
str = sprintf('Enter input amplitude [%f]: ', amp);
in =  input(str);
if(~isempty(in))
    amp = in;
end
%amp = 1.000; % amplitude of sine wave input to voltage divider

% The 2 is because amp half of the differenceial signal
vin = 2 * amp * (R2/(R2+R1)); 
%vin = sqrt(2) * vin / 2; % RMS

vin = 2 * amp / 10; % using 20db attenuator

[hdr, vout, time] = read_wispr_file(name, 2, 1024);

%vout(n) = max(data(:));
%vout = sqrt(mean(data(:).^2)); % RMS
vout = vout(:);

% plot data buffers S
figure(1); clf;
d = 50;
%plot(time(1:d:end,:), vout(1:d:end,:),'.-');
plot(vout(1:d:end),'-');
ylabel('Volts');
xlabel('Sample');
grid on;
%axis([min(min(time)) max(max(time)) -5.1 5.1]);

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

fft_size = 512;

% Calc spectrum of vout/vin
%window = rectwin(fft_size);
window = hamming(fft_size)*1.59; %multiply energy correction
%window = hann(fft_size)*1.63;
overlap = fft_size/8;
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


