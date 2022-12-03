function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'rotation3dobject');

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

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);


if doplot
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    for i = 1:length(strctDesign.m_astrctMedia);
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    end
    
    cc = [];
for i = 1:length(filename)
   fn = filename{i};
   if fn(end) == '1' && ~(fn(end-1) == '1')
       k(i) = 1;
   else
       k(i) = 0;
   end
end

j = 0;
for i = 1:length(filename)
    fn = filename{i};
    
    if k(i) == 1;
        j = j + 1;
        r(i) = 1;
        cc(i) = j;
        dd = fn(1:end-1);
    else
        r(i) = str2num(fn(length(dd)+1:end));
        cc(i) = j;
    end
end

windex = [];
for i = 1:max(cc)
    index = find(cc == i);
    if length(index) < 11
        delindex = find(cc == i);
            windex = [windex delindex];

    end
end

fr(windex) = [];

    
    
end


