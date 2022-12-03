function [consistency fr fr_half] = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'wholerotationimages');

[fr fr_half consistency]  = fnAveragePB_splitharf(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:2816)>0, strctUnit.m_aiPeriStimulusRangeMS, 60,220);

    



    