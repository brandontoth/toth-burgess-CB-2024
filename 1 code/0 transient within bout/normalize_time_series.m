function results = normalize_time_series(labels, photo_signal)

%% constants
Fs        = 1000;
epoch_len = 5  * Fs;
rem_min   = 20 * Fs;
results   = struct;

%% get rem info
sl_str  = parse_states(labels, 5, Fs);
rem_loc = sl_str.rem_loc * Fs;
rem_loc = [rem_loc(:, 1) rem_loc(:, 2) - epoch_len]; % cut off last 5 s of each bout
rem_len = rem_loc(:, 2) - rem_loc(:, 1);

% remove bouts < 20 s in len
rem_loc = rem_loc(rem_len > rem_min, :);
rem_len = rem_len(rem_len > rem_min);

% get max len
max_len = max(rem_len);

%% get transient array
peak_array = detect_transients(photo_signal, Fs);

% binarize transient locations
peak_array(~isnan(peak_array)) = 1;
peak_array(isnan(peak_array))  = 0;

%% preallocate interpolated arrays
norm_signal = nan(length(rem_len), max_len);
norm_peaks  = nan(length(rem_len), max_len);
xq          = nan(1, max_len);

%% iterate through bouts, resampling as you go
for i = 1:length(rem_len)
    cur_signal  = photo_signal(rem_loc(i, 1):rem_loc(i, 2) - 1);
    cur_peaks   = peak_array  (rem_loc(i, 1):rem_loc(i, 2) - 1);
    x           = 1:length(cur_signal);
    xq          = linspace(1, length(cur_signal), max_len); 

    norm_signal(i, :) = interp1(x, cur_signal, xq);
    norm_peaks (i, :) = interp1(x, cur_peaks,  xq);
end

%% calculate transient rate per epoch for every bout
str_epoch = 1; % counting variables  
end_epoch = epoch_len + 1;

% iterate through transient array
for i = 1:(size(norm_peaks, 2) / epoch_len)
    % cur epoch for saving purposes
    name = ['epoch_' num2str(i)];

    for k   = 1:size(norm_peaks, 1)
        rng = str_epoch:end_epoch;
    
        cur_epoch = norm_peaks(k, rng);
        cur_epoch = sum(cur_epoch);
    
        rate.(name)(k)  = cur_epoch / (numel(rng) / Fs);
    end
    
    rate.(name)  = rmmissing(rate.(name));

    if end_epoch <= size(norm_peaks, 2) - epoch_len
        str_epoch = str_epoch + epoch_len;
        end_epoch = end_epoch + epoch_len;
    end
end

% remove empty fields from struct
fn   = fieldnames(rate);
tf   = cellfun(@(c) isempty(rate.(c)), fn);
rate = rmfield(rate, fn(tf));

%% save everything to a struct
results.norm_signal = norm_signal;
results.norm_peaks  = norm_peaks;
results.rate        = rate;

[~, name, ~] = fileparts(pwd);
save([name '_results'], 'results')

end