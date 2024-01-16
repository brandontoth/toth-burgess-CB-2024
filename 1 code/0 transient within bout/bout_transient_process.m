function rate = bout_transient_process
%% housekeeping
% clear workspace
clear, clc, close all

% declare some variables
my_strct  = struct; % main struct
array_fs  = 1000;   % sampling rate
tot_bouts = 0;      % count total # of bouts
max_len   = 0;      % max bout length   
epoch_len = 5;      % epoch length in s

%% navigate to desired dir
selpath = uigetdir();
filedir = selpath;
cd(filedir);

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
D = D([D(:).isdir]);

%% iterate through folders
for k = 1:numel(D)
    %% load session data
    currD = D(k).name; % get the current subdirectory name
    cd(currD)          % change the directory

    fprintf(1, 'Now reading %s\n', currD);
    
    % get transient info
    [my_array, ~, rem, ~] = get_transient_array;
    
    % shove into structure
    my_strct.(currD).array = my_array;
    my_strct.(currD).bout  = rem;

    % update some info re: arrays
    tot_bouts = tot_bouts + length(rem);
    if size(my_array, 2) > max_len; max_len = size(my_array, 2); end

    %% return to the parent directory
    cd('..')
end

%% concatenate and removal of bouts
field       = fields(my_strct);        % struct fieldnames
all_bouts   = nan(tot_bouts, 1);       % preallocate bout array
all_trans   = nan(tot_bouts, max_len); % preallocate trans array
str = 1; en = 0; % counting variables for preallocation

% get all bout lengths into one array
for i = 1:length(field)
    curr_bout = my_strct.(field{i}).bout;
    curr_len  = (curr_bout(:, 2) - curr_bout(:, 1)) / array_fs;
    en = en + length(curr_len);

    all_bouts(str:en) = curr_len;

    str = en + 1;
end

% get all transients into one array
str = 1; en = 0;
for i = 1:length(field)
    curr_array = my_strct.(field{i}).array;
    en = en + size(curr_array, 1);

    all_trans(str:en, 1:size(curr_array, 2)) = curr_array;

    str = en + 1;
end

% get histogram for bout lengths, remove any bins that have a probability
% of less than 5 percent
% [n, ~, bin] = histcounts(all_bouts, 10, 'Normalization', 'probability');
% exclude_bin = find(n < 0.05);
% 
% all_trans(bin >= exclude_bin(1), :) = [];
% all_trans(all_bouts > 100, :) = []; % NOT PERM, TALK TO CB

%% calculate transient rate per epoch for every bout
epoch     = epoch_len * array_fs; % epoch length
str_epoch = 1;                    % counting variables  
end_epoch = epoch + 1;

% iterate through transient array
for i = 1:(size(all_trans, 2) / epoch)
    % cur epoch for saving purposes
    name = ['epoch_' num2str(i)];

    for k   = 1:size(all_trans, 1)
        rng = str_epoch:end_epoch;
    
        cur_epoch = all_trans(k, rng);
        cur_epoch = sum(cur_epoch);
    
        rate.(name)(k)  = cur_epoch / (numel(rng) / array_fs);
    end
    
    rate.(name)  = rmmissing(rate.(name));

    if end_epoch <= size(all_trans, 2) - epoch
        str_epoch = str_epoch + epoch;
        end_epoch = end_epoch + epoch;
    end
end

% remove empty fields from struct
fn   = fieldnames(rate);
tf   = cellfun(@(c) isempty(rate.(c)), fn);
rate = rmfield(rate, fn(tf));

end