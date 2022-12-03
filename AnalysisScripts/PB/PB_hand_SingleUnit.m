function [fr ff] = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'handandobj');

strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);

face = [1:11 15 44 53 54 66];
fruit = [12 13 17 18 19 34 37 38 39 41 59 60 61 70];
mammel = [14 16 25 26 32 33 36 42 43 64 65 67 68 71] 
bird = [20:24 55 56 57 58]
buttlefly = [27 28 29 30 40]
blank = [31 35 62 63 69 72 73 74 78]
cubic = [45 46 47 48 49 50:52]
noise = [75 76 77 79:83];

cc{1} = face;
cc{2} = fruit;
cc{3} = mammel;
cc{4} = bird;
cc{5} = buttlefly;
cc{6} = blank;
cc{7} = cubic;
cc{8} = noise;
a2bStimulusToCondition = zeros(190,9);
for i = 1:length(strctDesign.m_acMediaName)
    nn = strctDesign.m_acMediaName{i};
    if strcmpi(nn(1:4),'hand')
        a2bStimulusToCondition(i,1) = 1;
    else
        index = find(nn=='_');
        dd = str2num(nn(index(1)+1:index(2)-1));
        for j = 1:8
            if ismember(dd,cc{j})
                        a2bStimulusToCondition(i,j+1) = 1;
            end
        end
    end
end

fr = fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition,10,1);
ff = fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, diag(1:190)>1,10,1);
