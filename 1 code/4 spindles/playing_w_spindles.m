%% filt
Fs                       = 1000; % define sampling rate in Hz
dFs                      = 200;
movingWindow             = 750;  % define the size of the moving window in ms

dEEG = resample(EEG, dFs, Fs);
% design filter to focus EEG in the range of spindles
spindleFilt = designfilt('bandpassiir',  ... 
    'StopbandFrequency1', 3, 'PassbandFrequency1', 10, ...     
    'PassbandFrequency2', 15, 'StopbandFrequency2', 22, ...     
    'StopbandAttenuation1', 24, 'StopbandAttenuation2', 24, ...
    'SampleRate', dFs);

eegFilt = filtfilt(spindleFilt, dEEG); % get filtered EEG

% calculate RMS with a moving window of 750 ms to create envelope
eegFilt_env = envelope(eegFilt, movingWindow, 'rms'); 
% raise to the third power to amplify differences at higher thresholds
eegFilt_env = eegFilt_env .^ 3;

slp = parse_states(labels, 5, dFs);
trans = plotStateTransitions(normalize(eegFilt_env,'range'), slp, 30*dFs, dFs);

save_loc = 'D:\2 transitions\0 NAcc\Analysis\9 spindles';
[~, name, ~] = fileparts(pwd);
save([save_loc '\' name '_sigma_trans'],  'trans')
clear,clc,close all

%% cut
spn=findSpindles(EEG);

slp=parse_states(labels,5,dFs);
rem_str=slp.rem_loc(:,1)*dFs;
win=[rem_str-(30*dFs) rem_str];

for i=1:length(spn)
    for j=1:length(rem_str)
        if spn(i)>=win(j,1) && spn(i)<=win(j,2)
            no(i)=nan; yes(i)=spn(i); break
        else
            no(i)=spn(i);yes(i)=nan;
        end
    end
end
no=no'; yes=yes';
no(isnan(no))=[];
yes(isnan(yes))=[];

% nrem_loc=slp.nrem_loc*dFs;
% for i=1:length(spn)
%     for j=1:size(nrem_loc,1)
%         if spn(i)>nrem_loc(j,1) && spn(i)<nrem_loc(j,2)
%             nrem(i)=spn(i); break
%         else
%             nrem(i)=nan;
%         end
%     end
% end
% nrem=nrem';

signal=resample(smooth(photoSignal,750),200,1000);
sigma=cutAroundEvent(spn,6000,eegFilt_env);
fp=cutAroundEvent(no,6000,signal);
% 
save_loc = 'D:\2 transitions\0 NAcc\Analysis\9 spindles';
[~, name, ~] = fileparts(pwd);
save([save_loc '\' name '_sigma_pw'],  'sigma')
save([save_loc '\' name '_da_fp'],  'fp')
clear,clc,close all
%% plot
figure;
yyaxis left;e1=shadedErrorBar([],fp,{@mean @(x) std(x)./sqrt(size(fp,1))},'lineProps','b');
e1.mainLine.Color     = [1 1 1] * 0.3;
e1.patch.FaceColor    = [1 1 1] * 0.3;
ylabel('z-\DeltaF/F')
ylim([-0.05 0.25])
ax = gca;
ax.YColor = 'k';
hold on;
yyaxis right;shadedErrorBar([],sigma,{@mean @(x) std(x)./sqrt(size(sigma,1))},'lineProps','k')
ylabel('\sigma power (a.u.)')
ax = gca;
ax.YColor = 'k';
xlim([0 size(sigma,2)])
xticks([0 6000 12000])
xticklabels({'-30','0','30'})
xlabel('Time from spindle onset (s)')
%% norm
for i=1:size(sigma,1)
    sigma(i,:)=normalize(sigma(i,:),'range');
end
%% before after
for i=1:size(fp,1)
    before(i)=mean(fp(i,1:6000));
    after(i)=mean(fp(i,6001:end));
end

[h,p]=ttest(before,after);
%%
spindleSR = nan(length(dEEG), 1);
spindleSR(spn) = 1;

figure; 
tiledlayout(3,1);
a=nexttile;
plot(eegFilt_env); title 'Sigma power'
b=nexttile;
plot(eegFilt); title 'Bandpass EEG (10-15 Hz)'
c=nexttile;
plot(dEEG); title 'EEG'
% hold on; plot(eegFilt,'LineWidth',1); 
hold on; plot(spindleSR - 1 + mean(eegFilt), '*-g');
linkaxes([a b c], 'x')

%% spindle corr
[~,nrem_r]=find_spn(EEG,labels); 
% dFs=200;
% slp=parse_states(labels,5,dFs);
% 
% nrem=slp.nrem_loc*dFs;
% for i = 1:size(nrem, 1)
%     idx = find(spn >= nrem(i, 1) & spn <= nrem(i, 2));
%     dur = (nrem(i, 2) - nrem(i, 1)) / dFs;
% 
%     nrem_r(i) = numel(idx) / dur;
% end

[name, folder] = uigetfile('E:\2 transitions\0 NAcc\Analysis\1 transients - all bouts');
loc = fullfile(folder, name);
load(loc);

figure;scatter(nrem_r,rate.nrem_tot_rate)

spn_corr = [nrem_r rate.nrem_tot_rate'];

save_loc = 'E:\2 transitions\0 NAcc\Analysis\9 spindles\4 spn corr\1 ko light';
[~, name, ~] = fileparts(pwd);
save([save_loc '\' name '_spn_corr'],  'spn_corr')
clear,clc
%%
figure;scatter(spn(:, 1), spn(:, 2), 'filled', 'MarkerFaceColor', '#FFA500', 'SizeData', 10)
hold on
p = polyfit(spn(:, 1), spn(:, 2), 1);
f = polyval(p, spn(:, 1));
plot(spn(:, 1), f, 'k','LineWidth',2)
[r, val] = corrcoef(spn(:, 1), spn(:, 2));
title(['r^2 = ', num2str(r(2, 1)), ' p = ', num2str(val(2, 1))], 'FontWeight', 'normal')
ylabel('NREM transient rate (Hz)')
xlabel('Spindle rate (Hz)')
pbaspect([1 1 1])