function [a2fAvg, a2fstd, rr,a2bRaster,aiStimulusIndex] = fnAveragePB(a2bRaster, aiStimulusIndex, PeriStimulusRangeMS, iStartMS, iEndMS)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iStartAvg = find(PeriStimulusRangeMS>=iStartMS,1,'first');
iEndAvg = find(PeriStimulusRangeMS>=iEndMS,1,'first');
a2bRaster = sum(a2bRaster(:,iStartAvg:iEndAvg),2);

for i = 1:max(aiStimulusIndex)
    index = (aiStimulusIndex == i);
    a2fAvg(i) = mean(a2bRaster(index));
    a2fstd(i) = var(a2bRaster(index));
    rr{i} = a2bRaster(index);
end
    
return;
