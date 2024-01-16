function bout_state_space_w_beh
%% constant declaration
clear, clc, close all

epoch_len  = 5;    % epoch length in s
fs         = 1000; % sampling rate in Hz
down_fs    = 200;  % downsampled rate in Hz
wake_label = 2;    % AccuSleep wake label
nrem_label = 3;    % AccuSleep NREM label  
rem_label  = 1;    % AccuSleep REM label
cat_label  = 4;    % AccuSleep cataplexy label

%% load data
fprintf('Loading data. \n');

files = dir('*.mat');
for i = 1:length(files)
    if contains(files(i).name, 'EEG') || contains(files(i).name, 'Signal') || ...
            contains(lower(files(i).name), 'labels', 'IgnoreCase', true)   || ...
            contains(files(i).name, 'Food') || contains(files(i).name, 'Lick') || ...
            contains(files(i).name, 'RW')
        load(files(i).name)
    end
end
 
if exist('zPhotoSyncRight', 'var')
    photoSignal = zPhotoSyncRight;
elseif exist('zPhotoSyncLeft', 'var')
    photoSignal = zPhotoSyncLeft;
end

if exist('adjustedLabels', 'var')
    labels = adjustedLabels;
end

%% preprocess data and get transients
res        = remove_drift(photoSignal, fs); % baseline correct signal
peakArray  = new_transient_detection(res, fs);           % detect and make struct with transients
transients = quantify_transients(labels, peakArray, fs);

% downsampling
signal = resample(EEG, down_fs, fs);
food   = interp1(1:length(Food), Food, linspace(1, length(Food), down_fs * 3600 * 12))';
lick   = interp1(1:length(Lick), Lick, linspace(1, length(Lick), down_fs * 3600 * 12))';
rw     = interp1(1:length(RW),   RW,   linspace(1, length(RW),   down_fs * 3600 * 12))';

% interpolation creates some edge effects
% zero out anything that isn't the max value to clean up TTLs
food(food ~= 1) = 0; food = find(diff(food == 1));
lick(lick ~= 1) = 0; lick = find(diff(lick == 1));
rw  (rw   ~= 5) = 0; rw   = find(diff(rw   == 5));

%% sort all sleep bouts
% get sleep states
slp_str    = parse_states(labels, epoch_len, down_fs);

% loop through wake bouts and count beh
food_rate = nan(size(slp_str.wake_loc, 1), 1);
lick_rate = nan(size(slp_str.wake_loc, 1), 1);
rw_rate   = nan(size(slp_str.wake_loc, 1), 1);

for i = 1:size(slp_str.wake_loc, 1)
    cur_rng = slp_str.wake_loc(i, :) * down_fs;
    cur_len = (cur_rng(2) - cur_rng(1)) / down_fs / 5; % number of epochs in bout
    
    food_rate(i) = numel(find(food >= cur_rng(1) & food <= cur_rng(2))) / cur_len;
    lick_rate(i) = numel(find(lick >= cur_rng(1) & lick <= cur_rng(2))) / cur_len;
    rw_rate(i)   = numel(find(rw   >= cur_rng(1) & rw   <= cur_rng(2))) / cur_len;
end

% concatenate beh
wake_beh = [food_rate, lick_rate, rw_rate];

% concatenate bout LOCs, labels, and transient rates
wake_loc = [slp_str.wake_loc * down_fs zeros(length(slp_str.wake_loc), 1) + wake_label ...
    transients.wake_tot_rate'];
nrem_loc = [slp_str.nrem_loc * down_fs zeros(length(slp_str.nrem_loc), 1) + nrem_label ...
    transients.nrem_tot_rate'];
rem_loc  = [slp_str.rem_loc  * down_fs zeros(length(slp_str.rem_loc),  1) + rem_label ...
    transients.rem_tot_rate'];
if ~isempty(slp_str.cat_loc)
    cat_loc  = [slp_str.cat_loc * down_fs zeros(length(slp_str.cat_loc), 1) + cat_label ...
    transients.cat_tot_rate'];
end

% sort data to iterate through
if ~exist('cat_loc', 'var')
    all_bouts = [wake_loc; nrem_loc; rem_loc];
else
    all_bouts = [wake_loc; nrem_loc; rem_loc; cat_loc];
end
all_bouts = sortrows(all_bouts);
bout_dur  = all_bouts(:, 2) - all_bouts(:, 1);

%% filter data from 1-60 Hz
order      = 4;  % IIR filter order
fcutlow    = 1;  % lower bandpass freq
fcuthigh   = 60; % upper bandpass freq
[b, a]     = butter(order, [fcutlow fcuthigh] / (down_fs / 2), 'bandpass');
filt_sig   = filtfilt(b, a, signal');

%% run power analysis
ratio1 = nan(length(all_bouts), 1); % preallocate arrays
ratio2 = nan(length(all_bouts), 1);

for i    = 1:length(all_bouts)
    xdft = fft(filt_sig(all_bouts(i, 1):all_bouts(i, 2)));
    xdft = xdft(1:(bout_dur(i) / 2) + 1);
    psdx = (1 / (down_fs * bout_dur(i))) * abs(xdft) .^ 2;
    psdx(2:end - 1) = 2 * psdx(2:end - 1);
    
    one_hz     = floor(length(psdx) / (down_fs / 2));
    ratio1(i) = sum(psdx(one_hz * 6:one_hz * 10)) / sum(psdx(one_hz * 1:one_hz * 10));
    ratio2(i) = sum(psdx(one_hz * 1:one_hz * 16)) / sum(psdx(one_hz * 1:one_hz * 55));
end

%% plot everything
if ~exist('cat_loc', 'var')
    color = [0 1 0; 0 0 1; 1 0 0];
else
    color = [0 1 0; 0 0 1; 1 0 0; 1 0 1];
end

figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .6 .5])
ax1 = subplot(1, 2, 1);
scatter(ratio1, ratio2, 15, 'filled', 'CData', all_bouts(:, 3));
colormap(ax1, color);
shading interp  
colorbar();
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

ax2 = subplot(1, 2, 2);
scatter(ratio1, ratio2, 15, 'filled', 'CData', all_bouts(:, 4));
colormap(ax2, "jet"); caxis([0 0.35])
shading interp  
colorbar();
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

%% plot RW
ratio1_w = ratio1   (all_bouts(:, 3) == 2, :);
ratio2_w = ratio2   (all_bouts(:, 3) == 2, :);

figure;
scatter(ratio1_w, ratio2_w, 15, 'filled', 'CData', wake_beh(:, 3));
colormap("jet");
shading interp  
colorbar();
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

%% save results
save_loc     = 'E:\2 transitions\0 NAcc\Analysis\6 state space\3 all bout w beh';
[~, name, ~] = fileparts(pwd);
save([save_loc '\' name '_beh_state_space_light' '.mat'], 'ratio1', 'ratio2', 'all_bouts', 'wake_beh')

fprintf('Done running analysis. \n');

end