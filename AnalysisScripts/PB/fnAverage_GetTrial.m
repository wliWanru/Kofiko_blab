function a2f_trial= fnAveragePB(a2bRaster, aiStimulusIndex, a2bStimulusCategory, PeriStimulusRangeMS, iStartMS, iEndMS)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iStartAvg = find(PeriStimulusRangeMS>=iStartMS,1,'first');
iEndAvg = find(PeriStimulusRangeMS>=iEndMS,1,'first');
a2bRaster = mean(a2bRaster(:,iStartAvg:iEndAvg),2);

iNumStimuli = size(a2bStimulusCategory,1);
iNumCategories = size(a2bStimulusCategory,2);

iRaster_Length = size(a2bRaster,2);


a2fAvg = zeros(iNumCategories, iRaster_Length);
% a2fStd = zeros(iNumCategories, iRaster_Length);
aiCount = zeros(1,iNumCategories);

for i = 1:iNumCategories
    a2f_trial{i} = [];
end

for iIter=1:length(aiStimulusIndex)
    % Find which categories this stimulus belongs to
    aiCat = find(a2bStimulusCategory(aiStimulusIndex(iIter),:));
    % Add the Raster to matched categories
    abResponse = double(a2bRaster(iIter,:));
    bNaN = sum(isnan(abResponse)) > 0;
    if ~bNaN
        a2fAvg(aiCat,:) = a2fAvg(aiCat,:) + repmat(abResponse , length(aiCat),1);
        aiCount(aiCat) = aiCount(aiCat) + 1;
        a2f_trial{aiCat} = [a2f_trial{aiCat} repmat(abResponse , length(aiCat),1)];
    end    
end;






return;
