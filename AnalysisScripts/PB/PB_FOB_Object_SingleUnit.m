function [fr frmb ff2 tcc]= PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,cond)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'FOB');
if isempty(strctUnit)
    fr = nan;
    frmb = nan;
    ff2 = nan;
    tcc = nan;
    return;
end

tcs = strctUnit.m_a2fAvgFirintRate_Stimulus;
tcc = strctUnit.m_a2fAvgFirintRate_Category;
xx = max(strctUnit.m_aiStimulusIndex);
nn = zeros(96,2);
nn(1:16,1) = 1;
nn(17:end,2) = 1;

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);

frmb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220,-50,25);
ff = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid,nn , strctUnit.m_aiPeriStimulusRangeMS, 60, 220,-50,25);

ff2 = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid,nn , strctUnit.m_aiPeriStimulusRangeMS, 50, 200);

