clc; clear; close all;

%% ----------------------------------------------------
%  Filter Specifications
%% ----------------------------------------------------
Fs  = 256;       % Sampling frequency (Hz)
Fp  = 30;        % Passband edge (Hz)
Fs2 = 40;        % Stopband edge (Hz)

%% ----------------------------------------------------
%  Normalized cutoff frequency (0–1)
%  For fixed order, choose cutoff between Fp and Fs2
%% ----------------------------------------------------
Wn = Fp/(Fs/2);   % cutoff at passband edge (can also use (Fp+Fs2)/2)

%% ----------------------------------------------------
%  Fixed filter order
%% ----------------------------------------------------
n = 6;            % 6th order Butterworth

%% ----------------------------------------------------
%  Butterworth filter coefficients
%% ----------------------------------------------------
[b, a] = butter(n, Wn, 'low');

%% ----------------------------------------------------
%  1. Magnitude & Phase Response
%% ----------------------------------------------------
figure;
freqz(b, a, 2048, Fs);
title('6th Order Butterworth Filter: Magnitude and Phase Response');

%% ----------------------------------------------------
%  2. Pole–Zero Plot
%% ----------------------------------------------------
figure;
zplane(b, a);
title('Pole-Zero Plot of 6th Order Butterworth Filter');
grid on;

%% ----------------------------------------------------
%  3. Impulse Response
%% ----------------------------------------------------
figure;
impz(b, a);
title('Impulse Response of 6th Order Butterworth Filter');

%% ----------------------------------------------------
%  4. Step Response
%% ----------------------------------------------------
figure;
stepz(b, a);
title('Step Response of 6th Order Butterworth Filter');

%% ----------------------------------------------------
%  Detailed Magnitude Plot with dB scale
%% ----------------------------------------------------
figure;
[H, f] = freqz(b, a, 2048, Fs);
plot(f, 20*log10(abs(H)), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('6th Order Butterworth Magnitude Response (dB)');
