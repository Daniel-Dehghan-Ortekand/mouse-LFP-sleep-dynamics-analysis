% =========================================================================
% CLASS: TFR (Time-Frequency Representation)
% =========================================================================
% DESCRIPTION:
% A custom MATLAB class for storing, processing, and computing Time-Frequency 
% Representations (TFR) of neural data. It wraps the output of FieldTrip's 
% time-frequency analysis (via EEGLAB) and provides built-in methods for 
% baseline normalization (percent increase) and extracting valid time ranges 
% (accounting for wavelet edge effects).
%
% PROPERTIES:
%   - Power     : 2D array (Frequencies x Time) of power values (single).
%   - Time      : 1D array of time points (seconds).
%   - Freq      : 1D array of frequency bins (Hz).
%   - Fs        : Sampling frequency (Hz).
%   - TimeRange : (Dependent) The start and end times of the valid 
%                 (non-NaN) data, automatically calculated from the Power 
%                 matrix to exclude wavelet edge artifacts.
%
% METHODS:
%   - TFR()             : Constructor to initialize the object.
%   - BaselineIncrease  : Normalizes power to percent increase relative to 
%                         a specified pre-stimulus baseline period.
%   - Run (Static)      : Computes the TFR from raw continuous data using 
%                         FieldTrip's mtmconvol (multi-taper convolution) 
%                         method with 5 cycles per time window.
%
% DEPENDENCIES:
%   - EEGLAB Toolbox (pop_importdata)
%   - FieldTrip Toolbox (eeglab2fieldtrip, ft_freqanalysis)
% =========================================================================

classdef TFR
    %TFR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Power (:, :) single
        Time (1, :) double
        Freq (1, :) double
        Fs double
    end

    properties(Dependent)
        TimeRange
    end
    
    methods
        function obj = TFR(power, time, freq, fs)
            %TFR Construct an instance of this class
            %   Detailed explanation goes here
            obj.Power = power;
            obj.Time = time;
            obj.Freq = freq;
            obj.Fs = fs;
        end

        function p_norm = BaselineIncrease(obj, pre_range)
            pm = mean(obj.Power(:, pre_range), 2);
            p_norm = (obj.Power - pm) ./ pm;
        end

        function p_norm = DebugBaselineIncrease(obj, pre_range)
            pm = mean(obj.Power(:, pre_range), 2);
            p_norm = (obj.Power - pm) ./ pm;
        end

        function t_range = get.TimeRange(obj)
            t_range = (find(diff(isnan(obj.Power(1,:))) ~= 0) + [0 -1])/obj.Fs;
        end
    end

    methods(Static)
        function tfr = Run(data, base_frequency, fs)
            cfg = [];
            cfg.output       = 'pow';
            cfg.channel      = 'ROI';
            cfg.method       = 'mtmconvol';
            cfg.taper        = 'hanning';
            cfg.foi          = (base_frequency(1):0.25:base_frequency(2));
            cfg.t_ftimwin    = 5./cfg.foi;  % 5 cycles per time window
            cfg.trials       = 1;
            cfg.channel      = 1;
            cfg.fsample      = fs;
            cfg.toi          = (0:length(data)-1)/fs;
            cfg.pad          = 'nextpow2';
            
            eeg = pop_importdata('data', data, 'srate', fs);
            eeg.nbchan = 1;
            eeg.trials = 1;
            fteeg = eeglab2fieldtrip(eeg, 'preprocessing');
            
            fa = ft_freqanalysis(cfg, fteeg);
            
            tfr = TFR(squeeze(fa.powspctrm), fa.time, fa.freq, fs);
        end
    end
end

