function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

if ~isempty(experiment)
    matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
else
    matpath = ['D:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
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

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
% strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImageContrast\TwoImageContrast.xml', false, false);
% for i = 1:length(strctDesign.m_astrctMedia);
%     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
% end
% 
% for i = 1:length(filename)
%     fn = filename{i};
%     xx = find(fn == '_');
%     Name1 = fn(1:xx(1)-1);
%     CondMatrix(i,1) = findcond(Name1);
%     Name2 = fn(xx(1)+1:xx(2)-1);
%     CondMatrix(i,2) = findcond(Name2);
%     CC1 = fn(xx(2)+1:xx(2)+3);
%     CondMatrix(i,3) = str2num(CC1(end-1:end));
%     CC2 = fn(xx(3)+1:xx(3)+3);
%     CondMatrix(i,4) = str2num(CC2(end-1:end));
%     if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
%         CondMatrix(i,5) = 1;
%     else
%         CondMatrix(i,5) = 2;
%     end
% end

xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);


if doplot
strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImageContrast\TwoImageContrast.xml', false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

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

figure;
for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 2);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

cc = {'ro-','go-','bo-','co-','ko-'}
subplot(2,3,1);
for i = 1:5
    hold on;
    plot(resp(i,:),cc{i},'linewidth',2);
end

subplot(2,3,4);
for i = 1:5
    hold on;
    plot(resp(:,i),cc{i},'linewidth',2);
end

for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 1);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

subplot(2,3,2);
for i = 1:5
    hold on;
    plot(resp(i,:),cc{i},'linewidth',2);
end

subplot(2,3,5);
for i = 1:5
    hold on;
    plot(resp(:,i),cc{i},'linewidth',2);
end


for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

subplot(2,3,3);
for i = 1:5
    hold on;
    plot(resp(i,:),cc{i},'linewidth',2);
end

subplot(2,3,6);
for i = 1:5
    hold on;
    plot(resp(:,i),cc{i},'linewidth',2);
end
end
