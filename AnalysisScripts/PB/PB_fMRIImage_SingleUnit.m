function [fr fr_rb tc LFP] = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'fMRIImage');

xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
fr_rb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220,-50,25);
LFP = fnAverageBy(strctUnit.m_a2fLFP(strctUnit.m_abValidTrials,:), strctUnit.m_aiStimulusIndexValid,  diag(1:xx)>0,0);



k = 1;
for i = -100:20:400
    tc(:,k) = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, i, i+50);
    k = k + 1;
end