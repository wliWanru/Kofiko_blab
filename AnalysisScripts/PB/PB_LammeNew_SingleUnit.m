function fr=PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ClutterWithLamme*');

if isempty(strctUnit)
    fr = nan;
    return;
end

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

a2bStimulusToCondition = zeros(length(filename),64);
k = 1;
for i = 1:5
    for j = 1:5
        if ((i==1) && (j==1)) || ((i==5) && (j==5))|| ((i==1) && (j==5))|| ((i==5) && (j==1))
            sc(i,j) = 0;
        else
            sc(i,j) = k;
            k = k + 1;
            
        end
    end
end




for i = 1:length(filename);
    fn = filename{i};
    tt = find(fn=='_');
    attribute = fn(1:tt(1)-1);
    if strcmpi(attribute,'noisebk')%||(attribute,'clutterbk')
        a2bStimulusToCondition(i,85) = 1;
    elseif strcmpi(attribute,'clutterbk')
        a2bStimulusToCondition(i,86) = 1;
        
    else
        
        if strcmpi(attribute,'pure');
            k = 1;
        elseif strcmpi(attribute,'clutter');
            k = 2;
        elseif strcmpi(attribute,'noise');
            k = 3;
        elseif strcmpi(attribute,'Lamme');
            k = 4;
        end
        
        xnumber = str2num(fn(tt(2)+2:tt(3)-1));
        ynumber = str2num(fn(tt(3)+2:end));
        xx = (xnumber-50)/75+1;
        yy = (ynumber-50)/75+1;
        index = sc(xx,yy);
        a2bStimulusToCondition(i,4*(index-1)+k) = 1;
    end
end
[fr, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition, 10,1);
if doplot
    figure;
    
    for i = 1:4:84
        [m n] = find(sc == (i+3)/4);
        pn = (m-1) * 5 + n;
        subplot(5,5,pn);
        plot(-200:900,fr(i,:),'b-','linewidth',2);
        hold on;
        plot(-200:900,fr(i+1,:),'r-','linewidth',2);
        plot(-200:900,fr(i+2,:),'m-','linewidth',2);
        plot(-200:900,fr(i+3,:),'c-','linewidth',2);
        axis([-200 900 0 max(fr(:))]);
        box off;
        setgca;
    end
end

