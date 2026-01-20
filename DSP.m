%% ======================================
% EEG Alzheimer vs Normal (MAT + CSV)
% LOWPASS FIR HAMMING (0–30 Hz) + NOTCH 50 Hz
% ======================================

clc; clear; close all;

%% ========= GLOBAL SETTINGS =========
fs = 256;
fc = 30;          % cutoff frequency for LPF
order = 84;       % FIR Hamming order

% Notch Frequency (India)
fn = 50;
Q  = 35;

%% ========= Start Total Timer =========
full_start = tic;

%% =====================================
% 1) LOAD ALZHEIMER EEG (AD.mat)
%% =====================================
raw = load("AD.mat");
AD = raw.AD;

sub = 1; ch = 1; ep = 1;
sig_AD = squeeze(AD(sub).epoch(ch,:,ep));
sig_AD = sig_AD(:);

% DC Removal
sig_AD = sig_AD - mean(sig_AD);

N_AD = length(sig_AD);
t_AD = (0:N_AD-1)/fs;

%% =====================================
% 2) LOAD NORMAL EEG (CSV)
%% =====================================
sig_CT = readmatrix("features_raw.csv");
sig_CT = sig_CT(:,1);   % single channel
sig_CT = sig_CT(:);

% DC Removal
sig_CT = sig_CT - mean(sig_CT);

N_CT = length(sig_CT);
t_CT = (0:N_CT-1)/fs;

%% =====================================
% 3) NOTCH FILTER (50 Hz)
%% =====================================
w0 = fn/(fs/2);
bw = w0/Q;

[bN, aN] = iirnotch(w0, bw);

sig_AD_notch = filtfilt(bN, aN, sig_AD);
sig_CT_notch = filtfilt(bN, aN, sig_CT);

%% =====================================
% 4) FIR HAMMING LOWPASS (0–30 Hz)
%% =====================================
Wc = fc/(fs/2);

b = fir1(order, Wc, "low", hamming(order+1));
a = 1;

filt_AD = filtfilt(b, a, sig_AD_notch);
filt_CT = filtfilt(b, a, sig_CT_notch);

%% =====================================
% 5) BAND POWER FEATURES (0.5–30 Hz bands)
%% =====================================
computeBand = @(x) struct(...
 'delta',bandpower(x,fs,[0.5 4]),...
 'theta',bandpower(x,fs,[4 8]),...
 'alpha',bandpower(x,fs,[8 13]),...
 'beta', bandpower(x,fs,[13 30]),...
 'total',bandpower(x,fs,[0.5 30]) );

F_AD = computeBand(filt_AD);
F_CT = computeBand(filt_CT);

% Relative % band power
rel_AD = 100 .* [F_AD.delta F_AD.theta F_AD.alpha F_AD.beta] ./ F_AD.total;
rel_CT = 100 .* [F_CT.delta F_CT.theta F_CT.alpha F_CT.beta] ./ F_CT.total;

slow_AD = rel_AD(1) + rel_AD(2);
slow_CT = rel_CT(1) + rel_CT(2);

%% =====================================
% 6) SPECTRAL ENTROPY
%% =====================================
entropy_AD = spectralEntropy(filt_AD);
entropy_CT = spectralEntropy(filt_CT);

%% =====================================
% 7) HJORTH MOBILITY
%% =====================================
mobAD = hjorthMobility(filt_AD);
mobCT = hjorthMobility(filt_CT);

%% =====================================
% 8) RULE ENGINE
%% =====================================
rule = @(rel,ent,mob) ...
  ((rel(1)+rel(2))>55) + (rel(3)<20) + (ent<4.5) + (mob<0.40);

flag_AD = rule(rel_AD, entropy_AD, mobAD);
flag_CT = rule(rel_CT, entropy_CT, mobCT);

decision_AD = ternary(flag_AD>=3, "ALZHEIMER-LIKE EEG", "NORMAL EEG PATTERN");
decision_CT = ternary(flag_CT>=3, "ALZHEIMER-LIKE EEG", "NORMAL EEG PATTERN");

%% =====================================
% 9) PRINT RESULTS
%% =====================================
fprintf("\n=========== EEG FEATURE SUMMARY ===========\n");

disp("---- Alzheimer EEG ----");
fprintf("Delta  = %.2f %%\nTheta  = %.2f %%\nAlpha  = %.2f %%\nBeta   = %.2f %%\n", rel_AD);
fprintf("Slow-Wave (δ+θ) = %.2f %%\n", slow_AD);
fprintf("Entropy = %.3f   Mobility = %.3f\n", entropy_AD, mobAD);
fprintf("Rules Triggered = %d\n", flag_AD);
fprintf("Decision = %s\n\n", decision_AD);

disp("---- Normal EEG ----");
fprintf("Delta  = %.2f %%\nTheta  = %.2f %%\nAlpha  = %.2f %%\nBeta   = %.2f %%\n", rel_CT);
fprintf("Slow-Wave (δ+θ) = %.2f %%\n", slow_CT);
fprintf("Entropy = %.3f   Mobility = %.3f\n", entropy_CT, mobCT);
fprintf("Rules Triggered = %d\n", flag_CT);
fprintf("Decision = %s\n", decision_CT);

%% =====================================
% 10) TIME DOMAIN PLOTS
%% =====================================
figure;
subplot(2,1,1)
plot(t_AD, filt_AD, 'm'); grid on;
title("Filtered Alzheimer EEG (Notch + Hamming LPF 30 Hz)");
xlabel("Time (s)"); ylabel("Amplitude");

subplot(2,1,2)
plot(t_CT, filt_CT, 'g'); grid on;
title("Filtered Normal EEG (Notch + Hamming LPF 30 Hz)");
xlabel("Time (s)"); ylabel("Amplitude");

%% =====================================
% 11) BAND POWER BAR GRAPH
%% =====================================
bands = categorical({'Delta','Theta','Alpha','Beta'});
figure;
bar(bands, [rel_AD' rel_CT']);
legend("Alzheimer","Normal","Location","northoutside","Orientation","horizontal");
ylabel("Relative Power (%)");
title("EEG Band Power Comparison");
grid on;

%% =====================================
% 12) PIE CHARTS
%% =====================================
figure;
subplot(1,2,1)
pie(rel_AD, {'Delta','Theta','Alpha','Beta'});
title("Alzheimer EEG");

subplot(1,2,2)
pie(rel_CT, {'Delta','Theta','Alpha','Beta'});
title("Normal EEG");

%% =====================================
% 13) MAGNITUDE SPECTRUM (LINEAR)
%% =====================================
N = min(length(filt_AD), length(filt_CT));
f = fs*(0:(N/2))/N;

P1_AD = oneSidedFFT(filt_AD, N);
P1_CT = oneSidedFFT(filt_CT, N);

figure;
plot(f, P1_AD, 'm','LineWidth',1.4); hold on;
plot(f, P1_CT, 'g','LineWidth',1.4);
grid on;
xlabel("Frequency (Hz)");
ylabel("Magnitude");
title("Magnitude Spectrum of Hamming LPF EEG");
legend("Alzheimer EEG","Normal EEG");
xlim([0 60]);

%% =====================================
% 14) SPECTRUM COMPARISON (dB)
%% =====================================
figure;
plot(f, 20*log10(P1_AD+eps), 'm','LineWidth',1.3); hold on;
plot(f, 20*log10(P1_CT+eps), 'g','LineWidth',1.3);
xlabel("Frequency (Hz)");
ylabel("Magnitude (dB)");
title("EEG Spectrum Comparison (Filtered Signals)");
legend("Alzheimer","Normal");
grid on;
xlim([0 60]);

%% ========= TOTAL EXECUTION TIME =========
execution_time = toc(full_start);
fprintf("\nTotal Execution Time = %.6f seconds\n", execution_time);

%% =====================================
% ============ Helper Functions ==========
%% =====================================
function out = ternary(cond,a,b)
if cond, out = a; else, out = b; end
end

function P1 = oneSidedFFT(x, N)
X = fft(x, N);
P2 = abs(X/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
end

function H = spectralEntropy(x)
N = length(x);
X = abs(fft(x)/N);
X = X(1:floor(N/2)+1);
X(X==0) = eps;
p = X/sum(X);
H = -sum(p .* log2(p));
end

function mob = hjorthMobility(x)
m2 = mean(x.^2);
d1 = diff(x);
mob = sqrt(mean(d1.^2) / m2);
end
