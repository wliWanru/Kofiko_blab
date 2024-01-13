function [astrctIntervals,aiStart,aiEnd, aiLength] = fnGetIntervals(abVector)
% ~~ this func select all changes of photodiode
% ~~ get tps of photodiode value switch from above thresh to below thresh 
% ~~ I suspect the resting state of the photodiode is above threshold
% ~~ from above to below threshold, gives an aiEnd
% ~~ from below to above threshold, gives an aiStart
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


% ~~ find all place with switch value
% ~~ abVector 611==1, 612==0, then afDiff 611==0, 612==-1, 613==0
% ~~ abVector 798==0, 799==1, then afDiff 798==0, 799==1, 800==0
afDiff = diff([0;abVector(:);0]);  

% ~~ 0 to 1 is 1;      1 to 0 is -1; 
aiStart = find(afDiff == 1);
if isempty(aiStart)
    astrctIntervals = [];
    aiEnd =[];
    return;
end;

aiEnd = find(afDiff == -1) -1;

aiLength = aiEnd-aiStart+1;

for k=1:length(aiStart)
    astrctIntervals(k).m_iStart = aiStart(k);
    astrctIntervals(k).m_iEnd = aiEnd(k);
    astrctIntervals(k).m_iLength = aiEnd(k)-aiStart(k)+1;
end;

