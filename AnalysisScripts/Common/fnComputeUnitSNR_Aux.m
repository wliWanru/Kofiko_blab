function [fSNR,afSNR_Time] = fnComputeUnitSNR_Aux(a2fWaveforms, afTimestamps)
% Compute single unit Signal to noise ratio (see Kelly et al. J.
% Neuroscience 2007)
afMean = mean(a2fWaveforms,1);
% ~~ among all mean data (despite event recording time)
fDenominator = (max(afMean(:))-min(afMean(:)));

% ~~ each Waveform minus the mean waveform
a2fDiff = a2fWaveforms-repmat(afMean,size(a2fWaveforms,1),1);
% ~~ flatten all (63, 32) mat and get a std of all number within the mat
plot(1:32, mean(a2fDiff, 1))

SDe = std(a2fDiff(:));

% ~~~ ?? we only take whole minutes data 
% ~~~ and calculate SNR for every minute??? 
afTimeStampMinutes = (afTimestamps-afTimestamps(1))/60;
fNumberMinutes = ceil(max(afTimeStampMinutes));
aiBins = 0:fNumberMinutes;

[~,aiInd]=histc(afTimeStampMinutes, aiBins);
afSNR_Time = nans(1,1+fNumberMinutes);

for i=1:fNumberMinutes+1
    Tmp = a2fDiff(aiInd == i,:);  % ~~ select data within timeBin i
    if ~isempty(Tmp)
        afSNR_Time(i) = fDenominator/(2*std(Tmp(:))); % select noise data within this minute bin
    end
end
% ~~ overall SNR
fSNR = fDenominator / (2*SDe);  
% ~~ SNR for every minute (or each time bin, 0~1, 1~2, 2~3 ...min)
afSNR_Time = afSNR_Time;  

return
