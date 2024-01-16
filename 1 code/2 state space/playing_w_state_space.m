%% load data
clear, clc, close all

files = dir;
files = files(~ismember({files.name}, {'.', '..'}));

concat_bouts_wt  = []; concat_bouts_ko  = [];
concat_ratio1_wt = []; concat_ratio1_ko = [];
concat_ratio2_wt  = []; concat_ratio2_ko = [];
% beh_wt           = []; beh_ko           = [];
group = 'KO';

for k = 1:numel(files)
    % load session data
    curr_file = files(k).name; % get the current subdirectory name

    fprintf(1, 'Now reading %s\n', curr_file);

    tf = contains(curr_file, group);

    load(curr_file)
    
    if size(ratio1, 1) > size(ratio1, 2)
        ratio1 = ratio1';
    end
    if size(ratio2, 1) > size(ratio2, 2)
        ratio2 = ratio2';
    end

    if tf == 0
        concat_bouts_wt  = vertcat(concat_bouts_wt,  all_bouts);
        concat_ratio1_wt = horzcat(concat_ratio1_wt, ratio1);
        concat_ratio2_wt = horzcat(concat_ratio2_wt, ratio2);
%         beh_wt          = vertcat(beh_wt,          wake_beh);
    else
        concat_bouts_ko  = vertcat(concat_bouts_ko,  all_bouts);
        concat_ratio1_ko = horzcat(concat_ratio1_ko, ratio1);
        concat_ratio2_ko = horzcat(concat_ratio2_ko, ratio2);
%         beh_ko          = vertcat(beh_ko,          wake_beh);
    end

    clear all_bouts ratio1 ratio2
end

exclude1 = intersect(find(concat_ratio1_ko < 0.2),  find(concat_bouts_ko(:, 3) == 1));
exclude2 = intersect(find(concat_ratio2_ko > 0.95), find(concat_bouts_ko(:, 3) == 1));
exclude  = intersect(exclude1, exclude2);

concat_bouts_ko (exclude, :) = [];
concat_ratio1_ko(exclude)    = [];
concat_ratio2_ko(exclude)    = [];

exclude1 = intersect(find(concat_ratio1_ko < 0.2),  find(concat_bouts_ko(:, 3) == 4));
exclude2 = intersect(find(concat_ratio2_ko > 0.95), find(concat_bouts_ko(:, 3) == 4));
exclude  = intersect(exclude1, exclude2);

concat_bouts_ko (exclude, :) = [];
concat_ratio1_ko(exclude)    = [];
concat_ratio2_ko(exclude)    = [];
%% plot WT state space
color = [0 1 0; 0 0 1; 1 0 0];

figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .6 .35])
ax1 = subplot(1, 2, 1);
scatter(concat_ratio1_wt, concat_ratio2_wt, 15, 'filled', 'CData', concat_bouts_wt(:, 3));
colormap(ax1, color);
shading interp  
colorbar
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')
xlim([0 0.8])

ax2 = subplot(1, 2, 2);
scatter(concat_ratio1_wt, concat_ratio2_wt, 15, 'filled', 'CData', concat_bouts_wt(:, 4));
colormap(ax2, "jet"); caxis([0 0.35])
shading interp  
colorbar
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')
xlim([0 0.8])

linkaxes([ax1 ax2], 'xy')

set(gcf, 'renderer', 'Painters', 'PaperOrientation', 'landscape')
% print('WT_state_space', '-dpdf')

% concat_ratio1_wt=concat_ratio1_wt';
% concat_ratio2_wt=concat_ratio2_wt';
% ratio1_w_wt = concat_ratio1_wt(concat_bouts_wt(:, 3) == 2, :);
% ratio2_w_wt = concat_ratio2_wt(concat_bouts_wt(:, 3) == 2, :);

%% plot KO state space
color = [0 1 0; 0 0 1; 1 0 0; 1 0 1];

figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .4 .3])
ax1 = subplot(1, 2, 1);
scatter(concat_ratio1_ko, concat_ratio2_ko, 15, 'filled', 'CData', concat_bouts_ko(:, 3));
colormap(ax1, color);
shading interp  
colorbar
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

ax2 = subplot(1, 2, 2);
scatter(concat_ratio1_ko, concat_ratio2_ko, 15, 'filled', 'CData', concat_bouts_ko(:, 4));
colormap(ax2, "jet"); caxis([0 0.35])
shading interp 
colorbar
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

linkaxes([ax1 ax2], 'xy')

set(gcf, 'renderer', 'Painters', 'PaperOrientation', 'landscape')
% print('KO_state_space', '-dpdf')

% concat_ratio1_ko=concat_ratio1_ko';
% concat_ratio2_ko=concat_ratio2_ko';
% ratio1_w_ko = concat_ratio1_ko(concat_bouts_ko(:, 3) == 2, :);
% ratio2_w_ko = concat_ratio2_ko(concat_bouts_ko(:, 3) == 2, :);
% 
% figure;
% scatter(ratio1_w_ko, ratio2_w_ko, 15, 'filled', 'CData', beh_ko(:, 3));
% colormap("jet"); caxis([0 .2])
% shading interp  
% colorbar();
% xlabel('Ratio 1 (6-10/1-10 Hz)')
% ylabel('Ratio 2 (1-16/1-55 Hz)')


%% plot density WT
points = [concat_ratio1_wt; concat_ratio2_wt]';

% [N, C] = hist3(points, 'nbins', [25 25]);
[N, C] = hist3(points,'ctrs', {.05:.01:.75 .7:.01:1});

%Get polygon half widths
wx=C{1}(:);
wy=C{2}(:);
% display
figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .35])
H = pcolor(wx, wy, N');
box on
shading interp
set(H,'edgecolor','none');
colorbar
myColorMap = jet(256);
myColorMap(1,:) = 1;
colormap(myColorMap);
colorbar
caxis([0 10])
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')
%% plot density KO
points = [concat_ratio1_ko; concat_ratio2_ko]';

% [N, C] = hist3(points, 'nbins', [25 25]);
[N, C] = hist3(points,'ctrs', {.05:.01:.75 .7:.01:1});

%Get polygon half widths
wx=C{1}(:);
wy=C{2}(:);
% display
figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .35])
H = pcolor(wx, wy, N');
box on
shading interp
set(H,'edgecolor','none');
colorbar
myColorMap = jet(256);
myColorMap(1,:) = 1;
colormap(myColorMap);
colorbar
caxis([0 20])
xlabel('Ratio 1 (6-10/1-10 Hz)')
ylabel('Ratio 2 (1-16/1-55 Hz)')

%% look at nrem-rem density
nrem_rem_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) ~= 2 & concat_bouts_ko(:, 3) ~= 4);
nrem_rem_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) ~= 2 & concat_bouts_ko(:, 3) ~= 4);
nrem_rem_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) ~= 2 & concat_bouts_ko(:, 3) ~= 4, 4);
nrem_rem_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) ~= 2 & concat_bouts_ko(:, 3) ~= 4, 3);

nrem_rem_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) ~= 2);
nrem_rem_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) ~= 2);
nrem_rem_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) ~= 2, 4);
nrem_rem_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) ~= 2, 3);

[wt_n_nr, wt_e_nr] = histcounts(nrem_rem_wt(:, 1), 0:.008:0.8, 'Normalization', 'probability');
[ko_n_nr, ko_e_nr] = histcounts(nrem_rem_ko(:, 1), 0:.008:0.8, 'Normalization', 'probability');

% figure;
% histogram(nrem_rem_wt(:, 1), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
% hold on;  
% histogram(nrem_rem_ko(:, 1), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
% plot(wt_e_nr(1:end - 1), movmean(wt_n_nr, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.3);
% plot(wt_e_nr(1:end - 1), movmean(ko_n_nr, 5), 'LineWidth', 2, 'Color', '#00b300');
% xline(mean(concatRatio1_KO(concatBouts_KO(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', '--', 'Color', '#00b300')
% xline(mean(concatRatio1_WT(concatBouts_WT(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', '--', 'Color', [1 1 1] * 0.3)
% title('NREM v REM', 'FontWeight', 'normal')
% ylabel('Point density (probability)')
% xlabel('Ratio 1 (6-10/1-10 Hz)')
% legend({'WT', 'OX KO'})
% text(0.32, 0.04, 'NREM'); text(0.48, 0.04, 'REM'); 

%% look at nrem-wake density
nrem_wake_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) ~= 1 & concat_bouts_ko(:, 3) ~= 4);
nrem_wake_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) ~= 1 & concat_bouts_ko(:, 3) ~= 4);
nrem_wake_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) ~= 1 & concat_bouts_ko(:, 3) ~= 4, 4);
nrem_wake_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) ~= 1 & concat_bouts_ko(:, 3) ~= 4, 3);

nrem_wake_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) ~= 1);
nrem_wake_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) ~= 1);
nrem_wake_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) ~= 1, 4);
nrem_wake_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) ~= 1, 3);

[wt_n, wt_e] = histcounts(nrem_wake_wt(:, 2), 0.7:0.003:1, 'Normalization', 'probability');
[ko_n, ko_e] = histcounts(nrem_wake_ko(:, 2), 0.7:0.003:1, 'Normalization', 'probability');

% figure;
% histogram(nrem_wake_wt(:, 2), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
% hold on;  
% histogram(nrem_wake_ko(:, 2), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
% plot(wt_e(1:end - 1), movmean(wt_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.3);
% plot(ko_e(1:end - 1), movmean(ko_n, 5), 'LineWidth', 2, 'Color', '#00b300');
% xline(mean(concatRatio2_KO(concatBouts_KO(:,3)==2)),'LineWidth',2,'LineStyle','--','Color','#00b300')
% xline(mean(concatRatio2_WT(concatBouts_WT(:,3)==2)),'LineWidth',2,'LineStyle','--','Color',[1 1 1]*0.3)
% title('NREM v Wake', 'FontWeight', 'normal')
% ylabel('Point density (probability)')
% xlabel('Ratio 2 (1-16/1-55 Hz)')
% legend({'WT', 'OX KO'}, 'Location', 'northwest')
% text(0.83, 0.035, 'Wake'); text(0.88, 0.035, 'NREM'); 

%% look at nrem-rem transient projection
bins = 0:.008:0.8;

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_rem_ko(nrem_rem_ko(:, 1) >= cur_bin(1) & nrem_rem_ko(:, 1) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio1_tr(i) = mean(cur_rng);
end

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_rem_wt(nrem_rem_wt(:, 1) >= cur_bin(1) & nrem_rem_wt(:, 1) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio1_tr(i) = mean(cur_rng);
end

figure;
histogram(nrem_rem_wt(:, 1), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_rem_ko(:, 1), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.32, 0.04, 'NREM'); text(0.48, 0.04, 'REM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e_nr(1:end - 1), movmean(wt_n_nr, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.3);
plot(ko_e_nr(1:end - 1), movmean(ko_n_nr, 5), 'LineWidth', 2, 'Color', '#00b300', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
% ylim([0 0.15])
ax = gca;
ax.YColor = 'k';
plot(bins(1:end -1), movmean(wt_ratio1_tr, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.3, 'LineStyle', ':');
plot(bins(1:end -1), movmean(ko_ratio1_tr, 5), 'LineWidth', 2, 'Color', '#00b300', 'LineStyle', ':');
xline(mean(concat_ratio1_ko(concat_bouts_ko(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', '--', 'Color', '#00b300')
xline(mean(concat_ratio1_wt(concat_bouts_wt(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', '--', 'Color', [1 1 1] * 0.3)
xlabel('Ratio 1 (6-10/1-10 Hz)')
legend({'WT', 'OX KO'})

%% look at nrem-wake transient projection
bins = 0.7:0.003:1;

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_ko(nrem_wake_ko(:, 2) >= cur_bin(1) & nrem_wake_ko(:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio2_tr(i) = mean(cur_rng);
end

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_wt(nrem_wake_wt(:, 2) >= cur_bin(1) & nrem_wake_wt(:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio2_tr(i) = mean(cur_rng);
end

figure;
histogram(nrem_wake_wt(:, 2), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_wake_ko(:, 2), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.83, 0.035, 'Wake'); text(0.88, 0.035, 'NREM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e(1:end - 1), movmean(wt_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.3);
plot(ko_e(1:end - 1), movmean(ko_n, 5), 'LineWidth', 2, 'Color', '#00b300', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.15])
ax = gca;
ax.YColor = 'k';
plot(bins(1:end - 1), movmean(wt_ratio2_tr, 10), 'LineWidth', 2, 'Color', [1 1 1] * 0.3, 'LineStyle', ':');
plot(bins(1:end - 1), movmean(ko_ratio2_tr, 10), 'LineWidth', 2, 'Color', '#00b300', 'LineStyle', ':');
xline(mean(concat_ratio2_ko(concat_bouts_ko(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', '--', 'Color', '#00b300')
xline(mean(concat_ratio2_wt(concat_bouts_wt(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', '--', 'Color', [1 1 1] * 0.3)
title('NREM v Wake', 'FontWeight', 'normal')
xlabel('Ratio 2 (1-16/1-55 Hz)')
legend({'WT', 'OX KO'}, 'Location', 'northwest')

%% look at nrem-rem transient projection with err bars
bins = 0:.008:0.8;
ko_ratio1_tr = nan(length(bins), 140);

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_rem_ko(nrem_rem_ko(:, 1) >= cur_bin(1) & nrem_rem_ko(:, 1) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio1_tr(i, 1:length(cur_rng)) = cur_rng;
end

wt_ratio1_tr = nan(length(bins), 140);
for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_rem_wt(nrem_rem_wt(:, 1) >= cur_bin(1) & nrem_rem_wt(:, 1) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio1_tr(i, 1:length(cur_rng)) = cur_rng;
end

figure; sm = 10;
histogram(nrem_rem_wt(:, 1), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_rem_ko(:, 1), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.355, 0.018, 'NREM'); text(0.48, 0.02, 'REM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e_nr(1:end - 1), movmean(wt_n_nr, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(ko_e_nr(1:end - 1), movmean(ko_n_nr, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins', wt_ratio1_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins', ko_ratio1_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
xline(mean(concat_ratio1_ko(concat_bouts_ko(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', ':', 'Color', '#00b300')
xline(mean(concat_ratio1_wt(concat_bouts_wt(:, 3) == 1)), 'LineWidth', 2, 'LineStyle', ':', 'Color', [1 1 1] * 0.3)
title('NREM v REM', 'FontWeight', 'normal')
xlabel('Ratio 1 (6-10/1-10 Hz)')
legend({'WT', 'OX KO'}, 'Location', 'northwest')

%% look at nrem-wake transient projection with err bars
bins = 0.7:0.003:1;
ko_ratio2_tr = nan(length(bins), 200);

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_ko(nrem_wake_ko(:, 2) >= cur_bin(1) & nrem_wake_ko(:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;
end

wt_ratio2_tr = nan(length(bins), 200);
for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_wt(nrem_wake_wt(:, 2) >= cur_bin(1) & nrem_wake_wt(:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;
end

figure; sm = 10;
histogram(nrem_wake_wt(:, 2), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_wake_ko(:, 2), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.83, 0.035, 'Wake'); text(0.88, 0.035, 'NREM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e(1:end - 1), movmean(wt_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(ko_e(1:end - 1), movmean(ko_n, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins', wt_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins', ko_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
xline(mean(concat_ratio2_ko(concat_bouts_ko(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', '#00b300')
xline(mean(concat_ratio2_wt(concat_bouts_wt(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', [1 1 1] * 0.3)
title('NREM v Wake', 'FontWeight', 'normal')
xlabel('Ratio 2 (1-16/1-55 Hz)')
xlim([0.7 1])
legend({'WT', 'OX KO'}, 'Location', 'northwest')

%% look at rem density
bins1 = 0:.008:0.8;
ratio = 2;

rem_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) == 1);
rem_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) == 1);
rem_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) == 1, 4);
rem_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) == 1, 3);

rem_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) == 1);
rem_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) == 1);
rem_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) == 1, 4);
rem_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) == 1, 3);

[wt_n_r, wt_e_r] = histcounts(rem_wt(:, ratio), bins1, 'Normalization', 'probability');
[ko_n_r, ko_e_r] = histcounts(rem_ko(:, ratio), bins1, 'Normalization', 'probability');

ko_ratio1_rem = nan(length(bins1), 140);

for i = 1:length(bins1) - 1
    cur_bin = [bins1(i) bins1(i + 1)];
    cur_rng = rem_ko(rem_ko(:, ratio) >= cur_bin(1) & rem_ko(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio1_rem(i, 1:length(cur_rng)) = cur_rng;
end

wt_ratio1_rem = nan(length(bins1), 140);
for i = 1:length(bins1) - 1
    cur_bin = [bins1(i) bins1(i + 1)];
    cur_rng = rem_wt(rem_wt(:, ratio) >= cur_bin(1) & rem_wt(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio1_rem(i, 1:length(cur_rng)) = cur_rng;
end

% figure;
% histogram(rem_wt(:, ratio), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
% hold on;  
% histogram(rem_ko(:, ratio), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
% plot(wt_e_r(1:end - 1), movmean(wt_n_r, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
% plot(wt_e_r(1:end - 1), movmean(ko_n_r, 5), 'LineWidth', 2, 'Color', '#87d072');
% title('REM', 'FontWeight', 'normal')
% ylabel('Point density (probability)')
% xlabel('Ratio 1 (6-10/1-10 Hz)')
% legend({'WT', 'OX KO'})

figure; sm = 10;
histogram(rem_wt(:, ratio), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(rem_ko(:, ratio), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
ax = gca;
ax.YColor = 'k';
plot(wt_e_r(1:end - 1), movmean(wt_n_r, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(wt_e_r(1:end - 1), movmean(ko_n_r, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins1', wt_ratio1_rem', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins1', ko_ratio1_rem', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
title('REM', 'FontWeight', 'normal')
% xlabel('Ratio 1 (6-10/1-10 Hz)')
xlabel('Ratio 2 (1-16/1-55 Hz)')
legend({'WT', 'OX KO'}, 'Location', 'northwest')


%% look at wake density
bins2 = 0.7:0.003:1;
ratio = 1;

wake_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) == 2);
wake_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) == 2);
wake_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) == 2, 4);
wake_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) == 2, 3);

wake_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) == 2);
wake_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) == 2);
wake_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) == 2, 4);
wake_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) == 2, 3);

[wt_n_w, wt_e_w] = histcounts(wake_wt(:, ratio), bins2, 'Normalization', 'probability');
[ko_n_w, ko_e_w] = histcounts(wake_ko(:, ratio), bins2, 'Normalization', 'probability');

ko_ratio1_wake = nan(length(bins2), 140);

for i = 1:length(bins2) - 1
    cur_bin = [bins2(i) bins2(i + 1)];
    cur_rng = wake_ko(wake_ko(:, ratio) >= cur_bin(1) & wake_ko(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio1_wake(i, 1:length(cur_rng)) = cur_rng;
end

wt_ratio1_wake = nan(length(bins2), 140);
for i = 1:length(bins2) - 1
    cur_bin = [bins2(i) bins2(i + 1)];
    cur_rng = wake_wt(wake_wt(:, ratio) >= cur_bin(1) & wake_wt(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio1_wake(i, 1:length(cur_rng)) = cur_rng;
end

figure; sm = 10;
histogram(wake_wt(:, ratio), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(wake_ko(:, ratio), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
ax = gca;
ax.YColor = 'k';
plot(wt_e_w(1:end - 1), movmean(wt_n_w, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(wt_e_w(1:end - 1), movmean(ko_n_w, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins2', wt_ratio1_wake', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins2', ko_ratio1_wake', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
title('Wake', 'FontWeight', 'normal')
xlabel('Ratio 1 (6-10/1-10 Hz)')
% xlabel('Ratio 2 (1-16/1-55 Hz)')
legend({'WT', 'OX KO'}, 'Location', 'northwest')

%% look at nrem density
bins2 = 0:.008:0.8;
ratio = 1;

nrem_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) == 3);
nrem_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) == 3);
nrem_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) == 3, 4);
nrem_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) == 3, 3);

nrem_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) == 3);
nrem_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) == 3);
nrem_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) == 3, 4);
nrem_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) == 3, 3);

[wt_n_n, wt_e_n] = histcounts(nrem_wt(:, ratio), bins2, 'Normalization', 'probability');
[ko_n_n, ko_e_n] = histcounts(nrem_ko(:, ratio), bins2, 'Normalization', 'probability');

ko_ratio_nrem = nan(length(bins2), 140);

for i = 1:length(bins2) - 1
    cur_bin = [bins2(i) bins2(i + 1)];
    cur_rng = nrem_ko(nrem_ko(:, ratio) >= cur_bin(1) & nrem_ko(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio_nrem(i, 1:length(cur_rng)) = cur_rng;
end

wt_ratio_nrem = nan(length(bins2), 140);
for i = 1:length(bins2) - 1
    cur_bin = [bins2(i) bins2(i + 1)];
    cur_rng = nrem_wt(nrem_wt(:, ratio) >= cur_bin(1) & nrem_wt(:, ratio) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio_nrem(i, 1:length(cur_rng)) = cur_rng;
end

figure; sm = 10;
histogram(nrem_wt(:, ratio), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_ko(:, ratio), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
ax = gca;
ax.YColor = 'k';
plot(wt_e_n(1:end - 1), movmean(wt_n_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(wt_e_n(1:end - 1), movmean(ko_n_n, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins2', wt_ratio_nrem', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins2', ko_ratio_nrem', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
title('NREM', 'FontWeight', 'normal')
xlabel('Ratio 1 (6-10/1-10 Hz)')
% xlabel('Ratio 2 (1-16/1-55 Hz)')
legend({'WT', 'OX KO'}, 'Location', 'northwest')
%% look at nrem-wake transient projection with err bars + beh
bins = 0.7:0.003:1;
ko_ratio2_tr = nan(length(bins), 200);
ko_food      = nan(length(bins), 200);
ko_lick      = nan(length(bins), 200);
ko_rw        = nan(length(bins), 200);

wake_ko(:, 1) = concat_ratio1_ko(concat_bouts_ko(:, 3) == 2);
wake_ko(:, 2) = concat_ratio2_ko(concat_bouts_ko(:, 3) == 2);
wake_ko(:, 3) = concat_bouts_ko (concat_bouts_ko(:, 3) == 2, 4);
wake_ko(:, 4) = concat_bouts_ko (concat_bouts_ko(:, 3) == 2, 3);

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng  = nrem_wake_ko(nrem_wake_ko(:, 2) >= cur_bin(1) & nrem_wake_ko(:, 2) <= cur_bin(2), 3);
    cur_food = beh_ko      (wake_ko     (:, 2) >= cur_bin(1) & wake_ko     (:, 2) <= cur_bin(2), 1);
    cur_lick = beh_ko      (wake_ko     (:, 2) >= cur_bin(1) & wake_ko     (:, 2) <= cur_bin(2), 2);
    cur_rw   = beh_ko      (wake_ko     (:, 2) >= cur_bin(1) & wake_ko     (:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;

    if isempty(cur_food); cur_food = 0; end
    ko_food(i, 1:length(cur_food)) = cur_food;

    if isempty(cur_lick); cur_lick = 0; end
    ko_lick(i, 1:length(cur_lick)) = cur_lick;

    if isempty(cur_rw); cur_rw = 0; end
    ko_rw(i, 1:length(cur_rw)) = cur_rw;
end

wt_ratio2_tr = nan(length(bins), 200);
wt_food      = nan(length(bins), 200);
wt_lick      = nan(length(bins), 200);
wt_rw        = nan(length(bins), 200);

wake_wt(:, 1) = concat_ratio1_wt(concat_bouts_wt(:, 3) == 2);
wake_wt(:, 2) = concat_ratio2_wt(concat_bouts_wt(:, 3) == 2);
wake_wt(:, 3) = concat_bouts_wt (concat_bouts_wt(:, 3) == 2, 4);
wake_wt(:, 4) = concat_bouts_wt (concat_bouts_wt(:, 3) == 2, 3);

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_wt(nrem_wake_wt(:, 2) >= cur_bin(1) & nrem_wake_wt(:, 2) <= cur_bin(2), 3);
    cur_food = beh_wt      (wake_wt     (:, 2) >= cur_bin(1) & wake_wt     (:, 2) <= cur_bin(2), 1);
    cur_lick = beh_wt      (wake_wt     (:, 2) >= cur_bin(1) & wake_wt     (:, 2) <= cur_bin(2), 2);
    cur_rw   = beh_wt      (wake_wt     (:, 2) >= cur_bin(1) & wake_wt     (:, 2) <= cur_bin(2), 3);
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;

    if isempty(cur_food); cur_food = 0; end
    wt_food(i, 1:length(cur_food)) = cur_food;

    if isempty(cur_lick); cur_lick = 0; end
    wt_lick(i, 1:length(cur_lick)) = cur_lick;

    if isempty(cur_rw); cur_rw = 0; end
    wt_rw(i, 1:length(cur_rw)) = cur_rw;
end

figure; sm = 10;
t = tiledlayout(7, 1);
nexttile(1, [4 1]);
histogram(nrem_wake_wt(:, 2), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_wake_ko(:, 2), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.83, 0.035, 'Wake'); text(0.88, 0.035, 'NREM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e(1:end - 1), movmean(wt_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(ko_e(1:end - 1), movmean(ko_n, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins', wt_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins', ko_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
xline(mean(concat_ratio2_ko(concat_bouts_ko(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', '#00b300')
xline(mean(concat_ratio2_wt(concat_bouts_wt(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', [1 1 1] * 0.3)
title('NREM v Wake', 'FontWeight', 'normal')
xlabel('Ratio 2 (1-16/1-55 Hz)')
xlim([0.7 1])
legend({'WT', 'OX KO'}, 'Location', 'northwest')

nexttile(5);
e3 = shadedErrorBar(bins', ko_rw', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e3.mainLine.Color     = [1 1 1] * 0.3;
e3.mainLine.Color     = '#f28500';
e3.mainLine.LineStyle = ':';
e3.patch.FaceColor    = '#f28500';
hold on
e4 = shadedErrorBar(bins', wt_rw', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e4.mainLine.Color     = [1 1 1] * 0.3;
e4.mainLine.Color     = '#f28500';
e4.mainLine.LineStyle = '-';
e4.patch.FaceColor    = '#f28500';
ylabel({'Wheel turns'; 'per epoch'})
xlim([0.7 1])

nexttile(6);
e5 = shadedErrorBar(bins', ko_lick', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e5.mainLine.Color     = [1 1 1] * 0.3;
e5.mainLine.Color     = '#6495ed';
e5.mainLine.LineStyle = ':';
e5.patch.FaceColor    = '#6495ed';
hold on
e6 = shadedErrorBar(bins', wt_lick', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e6.mainLine.Color     = [1 1 1] * 0.3;
e6.mainLine.Color     = '#6495ed';
e6.mainLine.LineStyle = '-';
e6.patch.FaceColor    = '#6495ed';
ylabel({'Licks'; 'per epoch'})
xlim([0.7 1])

nexttile(7);
e7 = shadedErrorBar(bins', ko_food', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e7.mainLine.Color     = [1 1 1] * 0.3;
e7.mainLine.Color     = '#728c69';
e7.mainLine.LineStyle = ':';
e7.patch.FaceColor    = '#728c69';
hold on
e8 = shadedErrorBar(bins', wt_food', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e8.mainLine.Color     = [1 1 1] * 0.3;
e8.mainLine.Color     = '#728c69';
e8.mainLine.LineStyle = '-';
e8.patch.FaceColor    = '#728c69';
ylabel({'Pellets'; 'per epoch'})
legend({'OX KO'; 'WT'})
xlim([0.7 1])

%% look at state length distributions
ko_len = (concat_bouts_ko(:, 2) - concat_bouts_ko(:, 1)) / 200;
wt_len = (concat_bouts_wt(:, 2) - concat_bouts_wt(:, 1)) / 200;

ko_len_nw = ko_len(concat_bouts_ko(:, 3) ~= 1 & concat_bouts_ko(:, 3) ~= 4);
wt_len_nw = wt_len(concat_bouts_wt(:, 3) ~= 1 & concat_bouts_wt(:, 3) ~= 4);

bins = 0.7:0.003:1;
ko_ratio2_tr = nan(length(bins), 200);
ko_ratio2_ln = nan(length(bins), 200);

for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_ko(nrem_wake_ko(:, 2) >= cur_bin(1) & nrem_wake_ko(:, 2) <= cur_bin(2), 3);
    cur_len = ko_len_nw   (nrem_wake_ko(:, 2) >= cur_bin(1) & nrem_wake_ko(:, 2) <= cur_bin(2));
    
    if isempty(cur_rng); cur_rng = 0; end
    ko_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;

    if isempty(cur_len); cur_len = 0; end
    ko_ratio2_ln(i, 1:length(cur_len)) = cur_len;
end

wt_ratio2_tr = nan(length(bins), 200);
wt_ratio2_ln = nan(length(bins), 200);
for i = 1:length(bins) - 1
    cur_bin = [bins(i) bins(i + 1)];
    cur_rng = nrem_wake_wt(nrem_wake_wt(:, 2) >= cur_bin(1) & nrem_wake_wt(:, 2) <= cur_bin(2), 3);
    cur_len = wt_len_nw   (nrem_wake_wt(:, 2) >= cur_bin(1) & nrem_wake_wt(:, 2) <= cur_bin(2));
    
    if isempty(cur_rng); cur_rng = 0; end
    wt_ratio2_tr(i, 1:length(cur_rng)) = cur_rng;

    if isempty(cur_len); cur_len = 0; end
    wt_ratio2_ln(i, 1:length(cur_len)) = cur_len;
end

figure; sm = 10;
t = tiledlayout(6, 1);
nexttile(1, [4 1]);
histogram(nrem_wake_wt(:, 2), 100, 'FaceColor', [1 1 1] * 0.7, 'EdgeColor', [1 1 1] * 0.7, 'Normalization', 'probability')
hold on;  
histogram(nrem_wake_ko(:, 2), 100, 'FaceColor', '#87d072', 'EdgeColor', '#87d072', 'Normalization', 'probability')
yyaxis left
ylabel('Point density (probability)')
text(0.83, 0.035, 'Wake'); text(0.88, 0.035, 'NREM'); 
ax = gca;
ax.YColor = 'k';
plot(wt_e(1:end - 1), movmean(wt_n, 5), 'LineWidth', 2, 'Color', [1 1 1] * 0.7);
plot(ko_e(1:end - 1), movmean(ko_n, 5), 'LineWidth', 2, 'Color', '#87d072', 'LineStyle', '-');
yyaxis right
ylabel('Transient rate (Hz)')
ylim([0 0.3])
ax = gca;
ax.YColor = 'k';
e1 = shadedErrorBar(bins', wt_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e1.mainLine.Color     = [1 1 1] * 0.3;
% e1.mainLine.LineStyle = ':';
e1.patch.FaceColor    = [1 1 1] * 0.3;
e2 = shadedErrorBar(bins', ko_ratio2_tr', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)}, 'lineProps', 'g-');
e2.mainLine.Color     = '#00b300';
% e2.mainLine.LineStyle = ':';
e2.patch.FaceColor    = '#00b300';
xline(mean(concat_ratio2_ko(concat_bouts_ko(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', '#00b300')
xline(mean(concat_ratio2_wt(concat_bouts_wt(:, 3) == 2)), 'LineWidth', 2, 'LineStyle', ':', 'Color', [1 1 1] * 0.3)
title('NREM v Wake', 'FontWeight', 'normal')
xlabel('Ratio 2 (1-16/1-55 Hz)')
xlim([0.7 1])
legend({'WT', 'OX KO'}, 'Location', 'northwest')

nexttile(5, [2 1]);
e3 = shadedErrorBar(bins', wt_ratio2_ln', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e3.mainLine.Color     = [1 1 1] * 0.3;
e3.mainLine.Color     = '#f28500';
e3.mainLine.LineStyle = '-';
e3.patch.FaceColor    = '#f28500';
hold on
e4 = shadedErrorBar(bins', ko_ratio2_ln', {@(x) smooth(mean(x, 'omitnan'), sm), ...
    @(x) smooth(std(x, 0, 1, "omitnan") ./ sqrt(sum(~isnan(x))), sm)});
e4.mainLine.Color     = [1 1 1] * 0.3;
e4.mainLine.Color     = '#f28900';
e4.mainLine.LineStyle = ':';
e4.patch.FaceColor    = '#f28900';
ylabel('Bout length (s)')
xlim([0.7 1])
xlabel('Ratio 2 (1-16/1-55 Hz)')

