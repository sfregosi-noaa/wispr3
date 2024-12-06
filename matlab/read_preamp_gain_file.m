function [preamp] = read_preamp_gain_file(file)
% Read ascii preamp gain file.
% The gain curve has units of frequency in Hz and gain in db V^2/Hz.
% The sensitivity is used to convert to uPa.
% The file format should look like this example:
%  PREAMP GAIN
%  SN: EOS01
%  sensitivity: -176.00
%  nbins: 257
%  dfreq: 390.625
%  0.00, 24.73
%  390.63, 27.22
%  781.25, 30.51
%  ...
%  99609.38, 5.88
%  100000.00, 5.87
%

fp = fopen( file, 'r', 'ieee-le' );
str = fgets(fp, 32);
str = fgets(fp, 32);
sn = sscanf(str, 'SN: %s');
str = fgets(fp, 32);
q = sscanf(str, 'sensitivity: %f');
str = fgets(fp, 32);
nbins = sscanf(str, 'nbins: %f');
str = fgets(fp, 32);
dfreq = sscanf(str, 'dfreq: %f');
% read the gain bins
for n = 1:nbins
    str = fgets(fp, 32);
    a = sscanf(str, '%f, %f');
    preamp.freq(n) = a(1);
    preamp.gain(n) = a(2);
end
preamp.sn = sn;
preamp.hydro_sensitivity = q;
preamp.nbins = nbins;
preamp.dfreq = dfreq;

fclose(fp);
