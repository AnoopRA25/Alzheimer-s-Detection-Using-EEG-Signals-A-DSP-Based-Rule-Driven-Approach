# EEG Alzheimer vs Normal Classification using DSP (MATLAB)

This project analyzes EEG signals to differentiate **Alzheimer-like EEG** vs **Normal EEG** using **Digital Signal Processing (DSP)** techniques and a **rule-based classification engine**.

---

## 📌 Project Overview

EEG signals contain frequency-specific brain rhythm information. Alzheimer’s disease typically shows:

- Increased **Slow-wave activity** (**Delta + Theta**)
- Reduced **Alpha activity**
- Decrease in **signal complexity**
- Change in **mobility**

This MATLAB project filters EEG, extracts features like **Bandpower**, **Spectral Entropy**, and **Hjorth Mobility**, then classifies the signal using a set of rules.

---

## ⚙️ DSP Processing Pipeline

1. Load Alzheimer EEG from `AD.mat`
2. Load Normal EEG from `features_raw.csv`
3. **DC removal** (mean subtraction)
4. Apply **50 Hz Notch Filter** (remove powerline noise)
5. Apply **FIR Lowpass Filter (0–30 Hz)** using **Hamming window**
6. Extract EEG features:
   - Bandpower: Delta, Theta, Alpha, Beta
   - Relative Band Power (%)
   - Slow-wave ratio (Delta + Theta)
   - Spectral Entropy
   - Hjorth Mobility
7. Apply **rule-based classifier**
8. Plot:
   - Time domain filtered EEG
   - Band power comparison
   - Pie charts
   - FFT Spectrum (Linear + dB)

---

## 📂 Folder Structure

EEG-Alzheimer-Detection-DSP/
├── code/
│ └── EEG_Alzheimer_DSP.m
├── dataset/
│ ├── AD.mat
│ └── features_raw.csv
├── results/
│ ├── filtered_signals.png
│ ├── bandpower_bar.png
│ ├── piecharts.png
│ ├── spectrum_linear.png
│ └── spectrum_db.png
└── README.md


---

## 📊 Filters Used

### ✅ 1) Notch Filter (50 Hz)
Used to remove **India powerline noise**:
- Notch frequency = **50 Hz**
- Quality factor Q = **35**
- Implemented using **IIR Notch Filter**
- Applied using `filtfilt()` for zero-phase filtering

### ✅ 2) FIR Lowpass Filter (0–30 Hz)
EEG rhythm bands exist under 30 Hz:
- FIR order = **84**
- Window = **Hamming**
- Linear-phase FIR (no waveform distortion)
- Applied using `filtfilt()` for clean signal

---

## 🧠 Features Extracted

| Feature | Range | Meaning |
|--------|------|---------|
| Delta | 0.5–4 Hz | Deep sleep / slow-wave |
| Theta | 4–8 Hz | Memory + cognitive activity |
| Alpha | 8–13 Hz | Relaxed state |
| Beta | 13–30 Hz | Active thinking |
| Spectral Entropy | — | Signal spectral complexity |
| Hjorth Mobility | — | Frequency variation of signal |

---

## ✅ Rule-Based Decision Engine

A signal is classified as **ALZHEIMER-LIKE EEG** if **3 or more rules** are triggered:

- Slow-wave (Delta + Theta) > 55%
- Alpha < 20%
- Spectral Entropy < 4.5
- Hjorth Mobility < 0.40

---

## 🧾 Console Output (Feature Summary)

```text
=========== EEG FEATURE SUMMARY ===========
---- Alzheimer EEG ----
Delta  = 78.21 %
Theta  = 23.50 %
Alpha  = 5.78 %
Beta   = 2.75 %
Slow-Wave (δ+θ) = 101.71 %
Entropy = 5.934   Mobility = 0.126
Rules Triggered = 3
Decision = ALZHEIMER-LIKE EEG

---- Normal EEG ----
Delta  = 0.00 %
Theta  = 0.21 %
Alpha  = 32.53 %
Beta   = 67.43 %
Slow-Wave (δ+θ) = 0.21 %
Entropy = 9.393   Mobility = 0.406
Rules Triggered = 0
Decision = NORMAL EEG PATTERN

Total Execution Time = 17.100527 seconds
