function [a2bStimulusToCondition,acConditionNames,strImageListDescrip] = fnLoadSimpleStimFile(str);

flag_olddesign = 0;
for i = 1:15
    if strcmp(str,num2str(i))
        flag_olddesign = 1;
    end
end
if flag_olddesign
    index = str2num(str);
    
    switch index
        case 1
            cond = 0:15:345;
        case 2
            cond = 0:15:345;
        case 3
            cond = 0.2:0.4:2;
        case 4
            cond = 50:25:300;
        case 5
            cond = 1:4;
        case 6
            cond = 1:2;
        case 7
            cond = -400:40:400;
        case 8
            cond = -100:10:100;
        case 9
            dist = -200:25:200;
            k = 0;
            for i = 1:length(dist)
                for j = 1:length(dist)
                    k = k+1;
                end
            end
            cond = 1:k;
        case 10
            cond = 1:4;
        case 11
            cond = -10:2:10;
            
    end
else
    [Path fn] = fileparts(str);
    copyfile(str,[fn '.m'])
    ImageParameter.ImageKind = 1;
    ImageParameter.StimulusSizePix_X = 100;
    ImageParameter.StimulusSizePix_Y = 100;
    ImageParameter.SF_CyclePerDeg = 1;
    ImageParameter.BarWidth = 1;%g_strctParadigm.BarWidth.Buffer(1,:,g_strctParadigm.BarWidth.BufferIdx);
    ImageParameter.Contrast = 1;%g_strctParadigm.Contrast.Buffer(1,:,g_strctParadigm.Contrast.BufferIdx);
    ImageParameter.SurfaceColor = 255; %g_strctParadigm.SurfaceColor.Buffer(1,:,g_strctParadigm.SurfaceColor.BufferIdx);
    ImageParameter.StimulusPos = [512 384]; %g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);
    ImageParameter.Orientation = 0;%g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx);
    ImageParameter.Depth = 5; %g_strctParadigm.Depth.Buffer(1,:,g_strctParadigm.Depth.BufferIdx);
    ImageParameter.PPD = 25;%g_strctParadigm.PixelPerDegree;
    ImageParameter.ScreenCenter = [512 384];%g_strctStimulusServer.m_aiScreenSize(3:4)/2;
    eval(['ImageParameter = ' fn '(ImageParameter);']);
    cond = 1:length(ImageParameter.Cond_Name);
end

num = length(cond);
a2bStimulusToCondition = zeros(num,num);
for i = 1:num
    a2bStimulusToCondition(i,i) = 1;
end

for i = 1:num
    acConditionNames{i} = num2str(cond(i));
end

strImageListDescrip = str;
