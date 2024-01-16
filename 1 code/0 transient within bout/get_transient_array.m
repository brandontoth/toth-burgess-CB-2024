function [rem_array, nrem_array, rem, nrem] = get_transient_array
%% constant declaration
epoch_len    = 5;    % epoch length in s
Fs           = 1000; % sampling rate in Hz
down_Fs      = 60;   % downsampled rate in Hz
nrem_label   = 3;    % AccuSleep NREM label  
rem_label    = 1;    % AccuSleep REM label
min_rem_len  = 20;   % rem bouts should be at least 20 s in length
min_nrem_len = 30;   % nrem bouts should be at least 20 s in length

%% load data preprocess data
[photo_signal, labels] = load_data;

res = remove_drift(photo_signal, Fs); % get rid of REM drop

%% sort all sleep bouts
sl_str = parse_states(labels, epoch_len, down_Fs);

% concatenate bout LOCs and labels
nrem_loc  = [sl_str.nrem_loc * down_Fs zeros(length(sl_str.nrem_loc), 1) + nrem_label];
rem_loc   = [sl_str.rem_loc  * down_Fs zeros(length(sl_str.rem_loc),  1) + rem_label];
all_bouts = sortrows([nrem_loc; rem_loc]);

% extract NREM bouts
nrem     = all_bouts(all_bouts(:, 3) == nrem_label, :);
nrem_len = nrem(:, 2) - nrem(:, 1);
nrem(nrem_len < down_Fs * min_nrem_len, :)     = [];
nrem_len(nrem_len < down_Fs * min_nrem_len, :) = [];

% extract NREM prior to REM sleep
prior = nan(size(all_bouts, 1), size(all_bouts, 2));

for i = 2:length(all_bouts)
    if all_bouts(i, 3) == rem_label
        prior(i, :) = all_bouts(i - 1, :); 
    end
end

prior = rmmissing(prior);

% extract REM bouts
rem     = all_bouts(all_bouts(:, 3) == rem_label, :);
rem_len = rem(:, 2) - rem(:, 1);
rem(rem_len < down_Fs * min_rem_len, :)     = [];
rem_len(rem_len < down_Fs * min_rem_len, :) = [];

%% get transient array
peak_array  = detect_transients(res, Fs);

% binarize transient locations
peak_array(~isnan(peak_array)) = 1; 
peak_array(isnan(peak_array))  = 0;

%% make array of all NREM photometry bouts
max_bout   = max(nrem_len);
nrem_array = nan(size(nrem, 1), max_bout);

for i = 1:size(nrem_array, 1)
    nrem_array(i, 1:nrem_len(i)) = peak_array(nrem(i, 1):nrem(i, 2) - 1);
end

%% make array of all REM photometry bouts
max_bout  = max(rem_len);
rem_array = nan(size(rem, 1), max_bout);

for i = 1:size(rem_array, 1)
    rem_array(i, 1:rem_len(i)) = peak_array(rem(i, 1):rem(i, 2) - 1);
end

%% do the same thing, but on normalized time series
normalize_time_series(labels, res);

clc

end