function output = OcclusionAnalysis(foldername,unitnumber)
usePB = 1;
close all;
subjID = 'Rocco'; experiment = 'test';%foldername = '141026'; unitnumber = '001';
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_QuickTest_*.mat']);
strctUnit = load([matpath mat(1).name]);
strctUnit = strctUnit.strctUnit;

strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end


Response = strctUnit.m_afAvgFirintRate_Stimulus;
figure;
subplot(2,2,1)
hold on;
plot(10:20:90,Response(1:5),'ko-','linewidth',2);
plot(10:20:90,Response(21:25),'ro-','linewidth',2);
plot(10:20:90,Response(31:35),'bo-','linewidth',2);

subplot(2,2,2)
hold on;

plot(10:20:90,Response(6:10),'ko-','linewidth',2);
plot(10:20:90,Response(21:25),'ro-','linewidth',2);
plot(10:20:90,Response(36:40),'bo-','linewidth',2);

subplot(2,2,3)
hold on;

plot(10:20:90,Response(11:15),'ko-','linewidth',2);
plot(10:20:90,Response(26:30),'ro-','linewidth',2);
plot(10:20:90,Response(31:35),'bo-','linewidth',2);

subplot(2,2,4)
hold on;

plot(10:20:90,Response(16:20),'ko-','linewidth',2);
plot(10:20:90,Response(26:30),'ro-','linewidth',2);
plot(10:20:90,Response(36:40),'bo-','linewidth',2);