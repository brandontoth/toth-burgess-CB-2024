function peakArray = detect_transients(photoSignal, Fs)

% new function for more sensitive transient detection
% BT, June 2023

filtFP1 = designfilt('lowpassiir', 'FilterOrder', 2, ...
                'PassbandFrequency', 4, 'SampleRate', Fs);
filtSig1 = filtfilt(filtFP1, photoSignal);

filtFP2 = designfilt('lowpassiir', 'FilterOrder', 2, ...
                'PassbandFrequency', 40, 'SampleRate', Fs);
filtSig2 = filtfilt(filtFP2, photoSignal);

diffSig = filtSig1 - filtSig2;
diffSigSq = diffSig .^ 2;

threshCandidate = mean(diffSigSq) + std(diffSigSq);

[pks, locs] = findpeaks(diffSigSq, Fs, 'MinPeakHeight', threshCandidate);

locArray = nan(1, length(photoSignal));
for i = 1:length(locs)
    cur = floor(locs(i) * Fs);
    locArray(cur) = pks(i);
end

threshPeaks = mean(photoSignal) + std(photoSignal) * 2;

peakArray = nan(1, length(photoSignal));
for i = 1:length(locArray)
    if ~isnan(locArray(i)) && photoSignal(i) > threshPeaks
        peakArray(i) = photoSignal(i);
    end
end

figure;
plot(photoSignal)
hold on
plot(peakArray,'o')

end