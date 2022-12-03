function [fr frmb]= PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'fMRIImage');
if isempty(strctUnit)
    fr = nan;
    frmb = nan;
    ff2 = nan;
    tcc = nan;
    return;
end


xx = max(strctUnit.m_aiStimulusIndex);


fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);

frmb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200,-50,25);


return;