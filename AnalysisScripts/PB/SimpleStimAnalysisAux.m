function [AllFiringRate  All_Std  AllaiCount AllDescription AllRepeat] = SimpleStimAnalysisAux( strctUnit,StartMS,EndMS )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
iNumStimuli = length(strctUnit.m_acConditionNames);
if nargin < 3
    EndMS = 500;
end

if nargin < 2
    StartMS = 20;
end

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
        CondDescribe{i} = [dispcharacter 'Repeat ' num2str(sum(J==i))];
        Repeat(i) = sum(J == i);
        %disp(dispcharacter);
    end
else
    Choose = 1;
    CondDescribe =[];
    Repeat = 1;
    CondDescribe {1} = 'AlltheSame';
end

Choose = find(Repeat > 5 * iNumStimuli)
if isempty(Choose)
    [junk Choose] = max(Repeat);
end

for i = 1:length(Choose)
    index = Choose(i);
    condmask = (J == index);
    AllRepeat(i) = Repeat(index);
    m_a2bRaster_Valid = strctUnit.m_a2bRaster_Valid(find(condmask==1),:);
    aiStimulusIndexValid = strctUnit.m_aiStimulusIndexValid(find(condmask==1));
    [AvgFirintRate_Stimulus, AvgFirintRate_Stimulus_Std, aiCount] ...
        = fnAveragePB(m_a2bRaster_Valid,  aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, StartMS, EndMS);

    AllFiringRate(:,i) = AvgFirintRate_Stimulus; All_Std(:,i) = AvgFirintRate_Stimulus_Std; AllaiCount(:,i) = aiCount; AllDescription{i} = CondDescribe{index};
end

