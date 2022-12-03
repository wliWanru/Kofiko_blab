function fr = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'foveaface');


strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);

for i = 1:length(strctDesign.m_acMediaName)
    fl{i} = strctDesign.m_acMediaName{i};
end

mm = zeros(45,length(fl));

for i = 1:length(fl);
    fn = fl{i};
    index = find(fn == '_');
    cc = str2num(fn(index(1)-1));
    cl = str2num(fn(end));
    ss = fn(index(1)+1:index(2)-1);
    if strcmpi(ss,'blank');
        c2 = 0;
    else
        c2 = 1;
    end
    if cc == 0
        mm(cl,i) = 1;
    else
        if c2
            mm(cc * 5 + 20 + cl, i) = 1;
        else
            mm(cc * 5 + cl,i) = 1;
        end
    end
end

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, mm', strctUnit.m_aiPeriStimulusRangeMS, 60, 220);

if flag == 0
else
    figure;
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(10:20:90,fr(1:5),'ro-','linewidth',2);
        plot(10:20:90,fr(i*5+1:i*5+5),'bo-','linewidth',2);
        plot(10:20:90,fr(i*5+21:i*5+25),'ko-','linewidth',2);
    end
end







