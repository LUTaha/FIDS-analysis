%% Clear everything 
clc
clear all

%% Load the file here
% Rawdata=abfload('C:\Users\tajn\Downloads\DataFIDS\2023_07_26_0001.abf');

[taken_file,path]=uigetfile('Y:\Common\SLICE ELECTROPHYSIOLOGY\WHOLE CELL SETUP\FIDS\m68\','*.abf');
User_Input=fullfile(path,taken_file);

%%
Rawdata=abfload(User_Input);
fs=20000;
Baseline_correction_timepoint=0.98; % this is in seconds

%% Extract input and output signals
Output_signal=Rawdata(:,1);
Input_signal=Rawdata(:,2);

%% Baseline correction

% Calculate the baseline 
Baseline_value_OS=mean(Output_signal(1:fs*Baseline_correction_timepoint)); % Calculated JUST before the stimulation artefact

% Subtract Baseline from OS
BC_Output_signal=Output_signal-Baseline_value_OS; % Create a Baseline corrected (BC) signal

%% Invert the output signal - for future trough calculations 

BC_signal_inverted=BC_Output_signal*-1;

%% Smoothen the data

% Design a low-pass filter with cutoff frequency of 0.1 (adjust as needed)
cutoff_frequency = 0.0001;
filter_order = 300;
lp_filter = designfilt('lowpassfir', 'FilterOrder', filter_order, 'CutoffFrequency', cutoff_frequency);

% Apply the low-pass filter to the signal
smoothed_signal = filtfilt(lp_filter, BC_signal_inverted);

%% Plot both signals

figure(1)           
subplot(3,1,1)
plot(smoothed_signal,'b')
hold on
plot(BC_signal_inverted,'r')
title('Smoothed signal(BLUE) vs Normal signal (RED)')

%% Calculate the peaks and their respective locations

[Trough_values_OS_BC,locations_outputsignal]=findpeaks(smoothed_signal,'MinPeakHeight',6);

%% Correspond to the input signal samplepoints

figure(1)
subplot(3,1,2)
plot(BC_Output_signal)
hold on
xline(locations_outputsignal)
title('Identified all the troughs of the BC signal (NOT INVERTED)')

%% Correlate to the input signal

Value_of_IS=Input_signal(locations_outputsignal);

%% Input signal BC

% Calculate the baseline 
Baseline_value_IS=mean(Input_signal(1:fs*Baseline_correction_timepoint)); % Calculated JUST before the stimulation artefact

% Baseline correction
BC_Input_signal=Input_signal-Baseline_value_IS; % Create a Baseline corrected (BC) signal

% Correlate to Baseline Corrected (BC) input signal
Value_of_BC_IS=BC_Input_signal(locations_outputsignal);

%% plot the correlation

figure(1)
subplot(3,1,3)
plot(BC_Input_signal)
xline(locations_outputsignal)
title('Identified respective points on the Input signal')

%% Output the correct values

%Trough Values of the output signal (baseline corrected)
%Trough_values_OS_BC
% Corresponding value of the input signal (baseline corrected)
%Value_of_BC_IS

%% Divide the output by the input

Resistance=Trough_values_OS_BC./Value_of_BC_IS;
Resistance=Resistance*-1;
figure(2)
plot(Resistance)
title('Ouput/Input')

%% Create an output excel sheet

filename_Output='Trough values of baseline corrected Output Signal.xlsx';
writematrix(Trough_values_OS_BC,filename_Output)

filename_Input='Trough values of baseline corrected Input Signal.xlsx';
writematrix(Value_of_BC_IS,filename_Input)

filename_Input='Resistance values.xlsx';
writematrix(Resistance,filename_Input)


