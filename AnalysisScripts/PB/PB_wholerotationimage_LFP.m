function aLFP = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'wholerotationimages');


a2bStimulusToCondition = zeros(1224,51);
for i = 1:51;
    a2bStimulusToCondition((i-1)*24+1:i*24,i) = 1;
end

if ~isempty(strctUnit)
aLFP = fnAverageBy(strctUnit.m_a2fLFP(strctUnit.m_abValidTrials,:), strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition,0);
else
    aLFP = nan;
end
% k = 1;
% for i = -100:20:400
%     tc(:,k) = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, i, i+50);
%     k = k + 1;
% end
% 
% fr(isnan(fr)) = 0;
% fr_rb(isnan(fr_rb)) = 0;
% tc(isnan(tc)) = 0;




    