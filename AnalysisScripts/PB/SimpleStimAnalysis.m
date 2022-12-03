function OcclusionAnalysis(subjID,experiment,foldername,unitnumber,StimName)
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber '_Simple_Stim_' StimName '.mat']);
[matpath '*_Unit_' unitnumber '_Simple_Stim_' StimName '.mat']
if isempty(mat)
    disp('Cannot Find Matfile');
    return;
else
    strctUnit = load([matpath mat(1).name]);
end
strctUnit = strctUnit.strctUnit;
%load D:\PB\EphysData\Rocco\Test\140722\RAW\..\Processed\SingleUnitDataEntries\Rocco_2014-07-22_15-27-56_Exp_NaN_Ch_001_Unit_001_Simple_Stim_8.mat

sp = strctUnit.m_strctStimulusParams;
fdNames = fieldnames(sp);
k = 1; NameMask = zeros(size(fdNames));
for i = 1:length(fdNames)
    if ~(strcmp(fdNames{i},'m_afStimulusON_ALL_MS')| strcmp(fdNames{i},'m_afStimulusOFF_ALL_MS'));
        eval(['ParameterMatrix(k,:) = sp.' fdNames{i} ';']);
        k = k +1;
        NameMask(i) = 1;
    end
end
fdNames = fdNames(find(NameMask==1));

[Condition,I,J] = unique(ParameterMatrix','rows');
k = 1;
if ~(size(Condition,1) == 1)
    for i = 1:size(Condition,2);
        if length(unique(Condition(:,i)))== 1 % all condition are the same
        else
            dd(k) = i;
            k = k + 1;
        end
    end
    
    for i = 1:size(Condition,1);
        dispcharacter = [num2str(i) ' '];
        for j = 1:length(dd);
            dispindex = dd(j);
            dispcharacter = [dispcharacter fdNames{dispindex} ' '];
            dispcharacter = [dispcharacter num2str(Condition(i,dispindex)) ' '];
        end
        dispcharacter = [dispcharacter 'Repeat ' num2str(I(i))];
        disp(dispcharacter);
    end
    Choose = input('Which Conidition?\n','s');
else
    Choose = '1';
end
iStartMS = 30; iEndMS = 150;
iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS>iStartMS,1,'first');
iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS<iEndMS,1,'last');

iBaseStartMS = -25; iBaseEndMS = 25;
iStartBaseAvg = find(strctUnit.m_aiPeriStimulusRangeMS>iBaseStartMS,1,'first');
iEndBaseAvg = find(strctUnit.m_aiPeriStimulusRangeMS<iBaseEndMS,1,'last');


iNumStimuli = length(strctUnit.m_acConditionNames);


figure;

for i = 1:length(Choose);
    index = str2num(Choose(i));
    condmask = (J == index);
    condmask = ones(size(J));
    m_a2bRaster_Valid = strctUnit.m_a2bRaster_Valid(find(condmask==1),:);
    aiStimulusIndexValid = strctUnit.m_aiStimulusIndexValid(find(condmask==1));
    AvgFirintRate_Stimulus_TC  = 1e3 * fnAverageBy(m_a2bRaster_Valid, ...
        aiStimulusIndexValid, diag(1:iNumStimuli)>0,3,1);
    AvgFirintRate_Stimulus = mean(AvgFirintRate_Stimulus_TC(:, iStartAvg:iEndAvg),2);
    Baseline = mean(AvgFirintRate_Stimulus_TC(:, iStartBaseAvg:iEndBaseAvg),2);
    
    subplot(length(Choose),3,i*3-2);
    plot(strctUnit.m_aiPeriStimulusRangeMS,AvgFirintRate_Stimulus_TC);
    if ~strcmp(StimName,'RFmapping');
        subplot(length(Choose),3,i*3-1);
        Bar(1:iNumStimuli,AvgFirintRate_Stimulus)
        subplot(length(Choose),3,i*3);
        Bar(1:iNumStimuli,AvgFirintRate_Stimulus-Baseline)
    else
        subplot(length(Choose),3,i*3-1);
        imshow(imresize(reshape(AvgFirintRate_Stimulus,17,17),[340 340],'nearest'),[]);
        Colormap('Default');
        subplot(length(Choose),3,i*3);
        imshow(imresize(reshape(AvgFirintRate_Stimulus-Baseline,17,17),[340 340],'nearest'),[]);
                Colormap('Default');

    end
end


