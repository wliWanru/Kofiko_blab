function PB_ReduceTwoImage(subjID,experiment,foldername,unit1,unit2);
subjID = 'Ozomatli'; experiment = []; foldername = '150125';unit1 = '017'; unit2 = '019';
if ~isempty(experiment)
    matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
else
    matpath = ['D:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
end
mat1 = dir([matpath '*_Unit_' unit1 '_Passive_Fixation_New_ReduceTwoImage.mat']);
mat2 = dir([matpath '*_Unit_' unit2 '_Passive_Fixation_New_ReduceTwoImage.mat']);

if isempty(mat1) || isempty(mat2)
    return;
end

strctUnit1 = load([matpath mat1(1).name]);
strctUnit1 = strctUnit1.strctUnit;

strctUnit2 = load([matpath mat2(1).name]);
strctUnit2 = strctUnit2.strctUnit;

% strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit1.m_strImageListUsed, false, false);
% for i = 1:length(strctDesign.m_astrctMedia);
%     cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
%     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
% end
t1 = strctUnit1.m_afStimulusONTime;
t2 = strctUnit2.m_afStimulusONTime;

[junk i1 i2] = intersect(t1,t2);

if isempty(junk);
    return ;
else
    strctUnit1.m_a2bRaster_Valid = strctUnit1.m_a2bRaster_Valid(i1,:);
    strctUnit2.m_a2bRaster_Valid = strctUnit2.m_a2bRaster_Valid(i2,:);
    strctUnit1.m_aiStimulusIndexValid = strctUnit1.m_aiStimulusIndexValid(i1);
    strctUnit2.m_aiStimulusIndexValid = strctUnit2.m_aiStimulusIndexValid(i2);
end

[sc1,vsc1,rr1] = fnSpikeCountPB(strctUnit1.m_a2bRaster_Valid,  strctUnit1.m_aiStimulusIndexValid, strctUnit1.m_aiPeriStimulusRangeMS, 50, 150);
[sc2,vsc2,rr2] = fnSpikeCountPB(strctUnit2.m_a2bRaster_Valid,  strctUnit2.m_aiStimulusIndexValid, strctUnit2.m_aiPeriStimulusRangeMS, 50, 150);


indexmap = [1 3 8
    2 7  9
    6 4 5];

sc1 = sc1(indexmap); vsc1 = vsc1(indexmap); rr1 = rr1(indexmap);
sc2 = sc2(indexmap); vsc2 = vsc2(indexmap); rr2 = rr2(indexmap);



R1 = strctUnit1.m_afAvgFirintRate_Stimulus(indexmap);
S1 = strctUnit1.m_afAvgFirintRate_StimulusStd(indexmap);

R2 = strctUnit2.m_afAvgFirintRate_Stimulus(indexmap);
S2 = strctUnit2.m_afAvgFirintRate_StimulusStd(indexmap);
