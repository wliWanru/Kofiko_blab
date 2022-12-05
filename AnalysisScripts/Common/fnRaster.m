function [a2bRaster,aiPeriStimulusRangeMS, a2fAvgSpikeForm] = fnRaster( ...
    strctUnit, afStimulusTime, iBeforeMS, iAfterMS)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% -200..500 ( for example....)

% ~~ find -200 before and 900 after timepoints
aiPeriStimulusRangeMS = iBeforeMS:iAfterMS;
iNumTrials = length(afStimulusTime);
a2bRaster = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
a2fAvgSpikeForm = zeros(iNumTrials, size(strctUnit.m_a2fWaveforms,2));  % ~~ (119, 32)
warning off
for iTrialIter=1:iNumTrials
    % ~~ aiSpikesIndex! find if any spike start in the range of -0.2 to 0.9 s of
    %    stimulusON
    % ~~~ is this range too large????? 
    aiSpikesInd = find(...
        strctUnit.m_afTimestamps >= afStimulusTime(iTrialIter) + iBeforeMS/1e3 & ...
        strctUnit.m_afTimestamps <= afStimulusTime(iTrialIter) + iAfterMS/1e3);
    
    if ~isempty(aiSpikesInd)
        % ~~ mean spike form of a certain trial stimulus
        a2fAvgSpikeForm(iTrialIter,:) = mean(strctUnit.m_a2fWaveforms(aiSpikesInd,:),1);
        
        % ~~ if number of aiSpikesInd > 1, gives same length aiSpikeTimeBins (like n
        %    numbers )
        % ~~ aiSpikeTimesBins is the indices of timepoints that spikes start
        %    (timepoints in 1100 timepoints)
        aiSpikeTimesBins = 1+floor( ...
            (strctUnit.m_afTimestamps(aiSpikesInd)-afStimulusTime(iTrialIter)-iBeforeMS/1e3)*1e3);
        % ~~ count how many spikes are in every 1100 timepoints. mark the timepoint
        %    with number. if none then mark the timepoint with 0
        % ~~ (count spikes within every milliseconds of -200 ms to 900 ms)
        aiIncreaseCount = hist(aiSpikeTimesBins, 1:length(aiPeriStimulusRangeMS));
        a2bRaster(iTrialIter, :) = a2bRaster(iTrialIter, :) + aiIncreaseCount;
        
    end;
end;
%a2bRaster = a2bRaster > 0; % Ignore multiple spikes falling inside same bin ?
return;