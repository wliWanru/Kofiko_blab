function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'TwoImageUpdown');

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

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);


if doplot
    strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImagesUpDown\TwoImageUpdown.xml', false, false);
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
    end
    
    figure;
    
    
    cc = {'ro-','go-','bo-','co-','ko-'}
    
    for i = 10:20:90
        for j = 10:20:90
            index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j);
            m = (i+10)/20; n = (j+10)/20;
            resp(m,n) = fr(index);
        end
    end
    
    subplot(2,2,1);
    for i = 1:5
        hold on;
        plot(resp(i,:),cc{i},'linewidth',2);
    end
    
    subplot(2,2,3);
    for i = 1:5
        hold on;
        plot(resp(:,i),cc{i},'linewidth',2);
    end
    
    
    for i = 10:20:90
        for j = 10:20:90
            index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i);
            m = (i+10)/20; n = (j+10)/20;
            resp(m,n) = fr(index);
        end
    end
    
    subplot(2,2,2);
    for i = 1:5
        hold on;
        plot(resp(i,:),cc{i},'linewidth',2);
    end
    
    subplot(2,2,4);
    for i = 1:5
        hold on;
        plot(resp(:,i),cc{i},'linewidth',2);
    end
    
    
    figure;
    
    for i = 10:20:90
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
        m = (i+10)/20;
        RR(m,1) = fr(index);
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
        RR(m,2) = fr(index);
        index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
        RR(m,3) = fr(index);
    end
    
    subplot(1,2,1);
    cc = {'ko--','ro-','bo-'};
    for j = 1:3;
        plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
        hold on;
    end
    
    for i = 10:20:90
        index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
        m = (i+10)/20;
        RR(m,1) = fr(index);
        index = find(CondMatrix(:,1) ==  0 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
        RR(m,2) = fr(index);
        index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
        RR(m,3) = fr(index);
    end
    
    
    subplot(1,2,2);
    cc = {'ko--','ro-','bo-'};
    for j = 1:3;
        plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
        hold on;
    end
end

