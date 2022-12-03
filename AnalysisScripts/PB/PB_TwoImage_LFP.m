function [output aLFP] = OcclusionAnalysis(subjID,experiment,foldername,unitnumber)
usePB = 1;
%subjID = 'Rocco'; experiment = 'test'; foldername = '140827'; unitnumber = '008';
if ~isempty(experiment)
    matpath = ['C:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
else
    matpath = ['C:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
end

mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']);
[matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']
if isempty(mat)
    strctUnit = [];
    mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_TwoImage_*.mat']);
    [matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']
    if ~isempty(mat)
        strctUnit = load([matpath mat(1).name]);
        strctUnit = strctUnit.strctUnit;
        
        strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
        for i = 1:length(strctDesign.m_astrctMedia);
            cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
            filename{i} = strctDesign.m_astrctMedia(i).m_strName;
        end
    else
        output = nan;
        return;
    end
    
else
    strctUnit = load([matpath mat(1).name]);
    
    strctUnit = strctUnit.strctUnit;
    
    fid = fopen('\\192.168.50.15\StimulusSet\PB_TwoImages\twoimages.txt');
    C = textscan(fid,'%s');
    filename = C{1};
    fclose(fid);
    
    
    
    
    % strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    % for i = 1:length(strctDesign.m_astrctMedia);
    %     cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    %     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    % end
    
end
CondMatrix = zeros(length(filename),5);

for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    Name1 = fn(1:xx(1)-1);
    CondMatrix(i,1) = findcond(Name1);
    Name2 = fn(xx(1)+1:xx(2)-1);
    CondMatrix(i,2) = findcond(Name2);
    CC1 = fn(xx(2)+1:xx(2)+3);
    CondMatrix(i,3) = str2num(CC1(end-1:end));
    CC2 = fn(xx(3)+1:xx(3)+3);
    CondMatrix(i,4) = str2num(CC2(end-1:end));
    if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
        CondMatrix(i,5) = 1;
    else
        CondMatrix(i,5) = 2;
    end
end

% for i = 1:7
%     for j = 10:20:90
%         CRFindex(i,(j+10)/20,1) = find(CondMatrix(:,1) == i & CondMatrix(:,2) == 0 & CondMatrix(:,3) == j & CondMatrix(:,5) == 2); % Center
%         CRFindex(i,(j+10)/20,2) = find(CondMatrix(:,1) == i & CondMatrix(:,2) == 0 & CondMatrix(:,3) == j & CondMatrix(:,5) == 1); % Left
%         CRFindex(i,(j+10)/20,3) = find(CondMatrix(:,2) == i & CondMatrix(:,1) == 0 & CondMatrix(:,4) == j & CondMatrix(:,5) == 1); % Right
%     end
% end
a2bStimulusToCondition = zeros(size(CondMatrix,1),45);
for i = 1:size(CondMatrix,1)
    if CondMatrix(i,1) < 4 && CondMatrix(i,2) ==0 && CondMatrix(i,5) == 2;
        a2bStimulusToCondition(i,(CondMatrix(i,3)+10)/20) = 1;
    elseif CondMatrix(i,1) > 3 && CondMatrix(i,2) ==0 && CondMatrix(i,5) == 2;
        a2bStimulusToCondition(i,(110-CondMatrix(i,3))/20+5) = 1;
    elseif CondMatrix(i,1) < 4 && CondMatrix(i,2) >3 && CondMatrix(i,5) == 2;
        a2bStimulusToCondition(i,(CondMatrix(i,3)+10)/20+10) = 1;
    elseif CondMatrix(i,1) < 4 && CondMatrix(i,2) ==0 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(CondMatrix(i,3)+10)/20+15) = 1;
    elseif CondMatrix(i,1) == 0 && CondMatrix(i,2) >3 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(110-CondMatrix(i,4))/20+20) = 1;
    elseif CondMatrix(i,1) < 4 && CondMatrix(i,2) >3 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(CondMatrix(i,3)+10)/20+25) = 1;
    elseif CondMatrix(i,1) ==0  && CondMatrix(i,2) < 4 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(CondMatrix(i,4)+10)/20+30) = 1;
    elseif CondMatrix(i,1) > 3  && CondMatrix(i,2) == 0 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(110-CondMatrix(i,3))/20+35) = 1;
    elseif CondMatrix(i,1) > 3  && CondMatrix(i,2) < 4 && CondMatrix(i,5) == 1;
        a2bStimulusToCondition(i,(110-CondMatrix(i,3))/20+40) = 1;
    end
end
    

    strctUnit.m_a2fAvgLFPStimulus = fnAverageBy(strctUnit.m_a2fLFP(strctUnit.m_abValidTrials,:), strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition,0);
    aLFP = strctUnit.m_a2fAvgLFPStimulus;
    [xx index] = min(aLFP(:,300:500)');
    output(:,1) = xx;
    output(:,2) = index + 100;
% figure;
% hold on;
% for i = 1:3
% subplot(3,1,i)
% hold on;
% plot(aLFP(3+(i-1)*15,:),'r-','LineWidth',2);
% plot(aLFP(8+(i-1)*15,:),'b-','LineWidth',2);
% plot(aLFP(13+(i-1)*15,:),'k-','LineWidth',2);
% plot((aLFP(3+(i-1)*15,:)+aLFP(8+(i-1)*15,:))/2,'c--','LineWidth',2)
% end
% 
% figure;
% PB_TwoImage_SingleUnit(subjID,experiment,foldername,unitnumber);