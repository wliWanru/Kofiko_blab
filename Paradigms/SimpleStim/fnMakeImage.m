function bSuccess = fnMakeImage(filename)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm g_strctStimulusServer
strImageList = filename;
ImageParameter.ImageKind = g_strctParadigm.ImageKind.Buffer(1,:,g_strctParadigm.ImageKind.BufferIdx);
ImageParameter.StimulusSizePix_X = g_strctParadigm.StimulusSizePix_X.Buffer(1,:,g_strctParadigm.StimulusSizePix_X.BufferIdx);
ImageParameter.StimulusSizePix_Y = g_strctParadigm.StimulusSizePix_Y.Buffer(1,:,g_strctParadigm.StimulusSizePix_Y.BufferIdx);
ImageParameter.SF_CyclePerDeg = g_strctParadigm.SF_CyclePerDeg.Buffer(1,:,g_strctParadigm.SF_CyclePerDeg.BufferIdx);
ImageParameter.BarWidth = g_strctParadigm.BarWidth.Buffer(1,:,g_strctParadigm.BarWidth.BufferIdx);
ImageParameter.Contrast = g_strctParadigm.Contrast.Buffer(1,:,g_strctParadigm.Contrast.BufferIdx);
ImageParameter.SurfaceColor = g_strctParadigm.SurfaceColor.Buffer(1,:,g_strctParadigm.SurfaceColor.BufferIdx);
ImageParameter.StimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);
ImageParameter.Orientation = g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx);
ImageParameter.Depth = g_strctParadigm.Depth.Buffer(1,:,g_strctParadigm.Depth.BufferIdx);
ImageParameter.PPD = g_strctParadigm.PixelPerDegree;
ImageParameter.ScreenCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
[strPath, strFileName] = fileparts(filename);
eval(['ImageParameter = ' strFileName '(ImageParameter);']);

ParameterList = {'StimulusON_MS','StimulusOFF_MS','StimulusSizePix_X','StimulusSizePix_Y','Orientation','Contrast'};
if isfield(ImageParameter,'DefaultValue')
    
    for i = 1:length(ParameterList)
        if isfield(ImageParameter.DefaultValue,ParameterList{i})
            eval(['ParameterValue = num2str(ImageParameter.DefaultValue.' ParameterList{i} ');']);
            eval(['set(g_strctParadigm.m_strctControllers.m_h' ParameterList{i} 'Edit,''string'',ParameterValue);']);
            eval(['fnStandardEditCallback(g_strctParadigm.m_strctControllers.m_h' ParameterList{i} 'Slider,g_strctParadigm.m_strctControllers.m_h' ParameterList{i} 'Edit,''' ParameterList{i} ''');']);
        end
    end
    if isfield(ImageParameter.DefaultValue,'BackgroundColor')
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'BackgroundColor',ImageParameter.DefaultValue.BackgroundColor);
    end
end

% switch cond
%     case 1
%         ImageParameter.ImageKind = 1;
%         ImageParameter.Parameter_Name{1} = 'Orientation';
%         ImageParameter.Parameter_Value{1} = [0:15:345]';
%         for i = 1:length(ImageParameter.Parameter_Value{1});
%             ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
%         end
%     case 2
%         ImageParameter.ImageKind = 2;
%         ImageParameter.Parameter_Name{1} = 'Orientation';
%         ImageParameter.Parameter_Value{1} = [0:15:345]';
%         for i = 1:length(ImageParameter.Parameter_Value{1});
%             ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
%         end
%     case 3
%         ImageParameter.ImageKind = 1;
%         ImageParameter.Parameter_Name{1} = 'SF_CyclePerDeg';
%         ImageParameter.Parameter_Value{1} = [0.2:0.4:2]';
%         for i = 1:length(ImageParameter.Parameter_Value{1});
%             ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
%         end
%     case 4
%         ImageParameter.ImageKind = 1;
%         ImageParameter.Parameter_Name{1} = 'StimulusSizePix_X';
%         ImageParameter.Parameter_Value{1} = [50:25:300]';
%         ImageParameter.Parameter_Name{2} = 'StimulusSizePix_Y';
%         ImageParameter.Parameter_Value{2} = [50:25:300]';
%
%         for i = 1:length(ImageParameter.Parameter_Value{1});
%             ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
%         end
%     case 5
%         ImageParameter.ImageKind = 3;
%         ImageParameter.Parameter_Name{1} = 'SurfaceColor';
%         ImageParameter.Parameter_Name{2} = 'BackgroundColor';
%         ImageParameter.Parameter_Name{3} = 'StimulusPos';
%         ImageParameter.Cond_Name = {'p11','p12','p21','p22'};
%         ImageParameter.Parameter_Value{1} = [0 128 128 0]';
%         ImageParameter.Parameter_Value{2} = repmat([128 0 0 128]',1,3);
%         theta = mod(ImageParameter.Orientation/180*pi,pi);
%         pos(1:2,:) = repmat([ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
%         pos(3:4,:) = repmat([ImageParameter.StimulusPos]+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
%         ImageParameter.Parameter_Value{3} = pos([1 4 2 3],:);
%     case 6
%         ImageParameter.ImageKind = 3;
%         ImageParameter.Parameter_Name{1} = 'SurfaceColor';
%         ImageParameter.Parameter_Value{1} = [0 255 ]';
%         ImageParameter.Cond_Name = {'Black', 'White'};
%     case 7
%         ImageParameter.ImageKind = 4;
%         ImageParameter.Parameter_Name{1} = 'StimulusPos';
%         dist = -400:40:400;
%         theta = mod(ImageParameter.Orientation/180*pi,pi);
%         for i = 1:length(dist)
%             pp(i,:) = [ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*(dist(i)+ImageParameter.StimulusSizePix_Y/2);
%             ImageParameter.Cond_Name{i} = num2str(dist(i));
%         end
%         ImageParameter.Parameter_Value{1} = pp;
%     case 8
%         ImageParameter.ImageKind = 4;
%         ImageParameter.Parameter_Name{1} = 'StimulusPos';
%         dist = -100:10:100;
%         theta = mod(ImageParameter.Orientation/180*pi,pi);
%         for i = 1:length(dist)
%             pp(i,:) = [ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*(dist(i)+ImageParameter.StimulusSizePix_Y/2);
%             ImageParameter.Cond_Name{i} = num2str(dist(i));
%         end
%         ImageParameter.Parameter_Value{1} = pp;
%     case 9
%         ImageParameter.ImageKind = 3;
%         ImageParameter.SurfaceColor = 255;
%         ImageParameter.Parameter_Name{1} = 'StimulusPos';
%         ImageParameter.Orientation = 0;
%         dist = -200:25:200;
%         k = 1;
%         for i = 1:length(dist)
%             for j = 1:length(dist)
%                 pp(k,:) = [ImageParameter.StimulusPos] + [dist(i) dist(j)];
%
%                 ImageParameter.Cond_Name{k} = [num2str(dist(i)) '_' num2str(dist(j))];
%                 k = k + 1;
%             end
%         end
%                 ImageParameter.Parameter_Value{1} = pp;
%     case 10
%         ImageParameter.ImageKind = 5;
%         ImageParameter.Parameter_Name{1} = 'StimulusPos';
%         ImageParameter.Parameter_Name{2} =  'Depth';
%         theta = mod(ImageParameter.Orientation/180*pi,pi);
%         ImageParameter.StimulusPos = ImageParameter.StimulusPos- g_strctStimulusServer.m_aiScreenSize(3:4)/2;
%         pos(1:2,:) = repmat([ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
%         pos(3:4,:) = repmat([ImageParameter.StimulusPos]+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
%         ImageParameter.Parameter_Value{2} = [ImageParameter.Depth -ImageParameter.Depth  -ImageParameter.Depth  ImageParameter.Depth]';
%         ImageParameter.Parameter_Value{1} = pos([1 4 2 3],:);;
%         ImageParameter.Cond_Name = {'p11','p12','p21','p22'};
%     case 11
%         ImageParameter.ImageKind = 5;
%         ImageParameter.Parameter_Name{1} = 'Depth';
%         ImageParameter.StimulusPos = ImageParameter.StimulusPos- g_strctStimulusServer.m_aiScreenSize(3:4)/2;
%         theta = mod(ImageParameter.Orientation/180*pi,pi);
%         ImageParameter.Parameter_Value{1} = -10:2:10
%
%      for i = 1:length(ImageParameter.Parameter_Value{1});
%             ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
%      end
% end



g_strctParadigm.Parameter_Name = ImageParameter.Parameter_Name;
g_strctParadigm.Parameter_Value = ImageParameter.Parameter_Value;

fnParadigmToStimulusServer('PauseButRecvCommands');

if fnParadigmToKofikoComm('IsPaused')
    fnParadigmToStimulusServer('Resume');
    fnParadigmToStimulusServer('MakeImageList',ImageParameter);
    fnParadigmToStimulusServer('Pause');
else
    fnParadigmToStimulusServer('MakeImageList',ImageParameter);
end





bSuccess  = false;

fnParadigmToStimulusServer('PauseButRecvCommands');

fnParadigmToKofikoComm('ClearMessageBuffer');
tt = GetSecs;
fnParadigmToKofikoComm('DisplayMessageNow','Making Image ...');
fnLog('Switching to a new list');
% This will pass on the message even if the draw cycle is paused....
strctDesign = fnMakeImageAux(ImageParameter);
if isempty(strctDesign)
    % Loading failed!
    return;
end;

g_strctParadigm.m_bJustLoaded = true;
g_strctParadigm.m_strctDesign = strctDesign;
iNumMediaInBlock = length(strctDesign.CurrentParameter);

if isfield(g_strctParadigm,'ImageList')
    fnTsSetVarParadigm('ImageList',strImageList);
else
    g_strctParadigm.m_strctStimulusParams =fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageList',num2str(cond));
end


fnTsSetVarParadigm('Designs', strctDesign);
fnDAQWrapper('StrobeWord', fnFindCode('Image List Changed'));

g_strctParadigm.m_iLastStimulusPresentedIndex  = 0;
g_strctParadigm.m_strctCurrentTrial = [];
fnParadigmToKofikoComm('ResetStat');

if g_strctParadigm.m_bRandom
    [fDummy,g_strctParadigm.DisplayOrder] = sort(rand(1,iNumMediaInBlock));
    
else
    g_strctParadigm.DisplayOrder = 1:iNumMediaInBlock;
end
% Update order and  blocks

% acBlockNames = {strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
% acBlockNames = acBlockNames(strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_aiBlockIndexOrder);
% acOrderNames = {strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder.m_strOrderName};
%
% % if isfield(g_strctParadigm,'m_strctControllers')
% %     set(g_strctParadigm.m_strctControllers.m_hBlockOrderPopup,'String',acOrderNames,'value',1);
% %     set(g_strctParadigm.m_strctControllers.m_hBlockLists,'String',acBlockNames,'value',1);
% % end
%
%
if g_strctParadigm.m_iMachineState > 0
    g_strctParadigm.m_iMachineState = 2; % This will prevent us to get stuck waiting for some stimulus server code
end
g_strctParadigm.m_bDoNotDrawThisCycle = true; % first, allow initialization of stuff, like selection of next image from the NEW image list


% Deal with StatServer Later
% if fnParadigmToStatServerComm('IsConnected')
%     if isempty(g_strctParadigm.m_strctDesign.m_a2bStimulusToCondition)
%         % There is no category file defiend for this list.
%         iNumStimuli =  length( g_strctParadigm.m_strctDesign.m_astrctMedia);
%         g_strctParadigm.m_strctStatServerDesign.TrialTypeToConditionMatrix = zeros(iNumStimuli,0);
%         g_strctParadigm.m_strctStatServerDesign.ConditionOutcomeFilter = cell(0);
%         g_strctParadigm.m_strctStatServerDesign.ConditionNames = cell(0);
%         g_strctParadigm.m_strctStatServerDesign.ConditionVisibility = [];
%     else
NumConditions = iNumMediaInBlock;
g_strctParadigm.m_strctStatServerDesign.NumberofConditionsInSimpleStim = NumConditions;

if ~isfield(ImageParameter,'TrialToConditionMode')
    g_strctParadigm.m_strctStatServerDesign.TrialToConditionMode = 1;
    g_strctParadigm.m_strctStatServerDesign.ConditionOutcomeFilter = cell(1,NumConditions); % No need for fancy averaging according

else
    g_strctParadigm.m_strctStatServerDesign.TrialToConditionMode = ImageParameter.TrialToConditionMode;
    g_strctParadigm.m_strctStatServerDesign.ConditionOutcomeFilter = cell(1,1); % No need for fancy averaging according

end


% to trial outcome, because we are going to drop all bad
% fixations...
g_strctParadigm.m_strctStatServerDesign.DesignName = strFileName;
if isfield(ImageParameter,'Cond_Name')
    g_strctParadigm.m_strctStatServerDesign.ConditionNames = ImageParameter.Cond_Name;
else
    g_strctParadigm.m_strctStatServerDesign.ConditionNames = [];
end


if isfield(ImageParameter,'STA');
    g_strctParadigm.m_strctStatServerDesign.STA_Cond_Name = ImageParameter.STA.Name;
    if strcmp(ImageParameter.STA.Name,'WhiteNoise')
        g_strctParadigm.m_strctStatServerDesign.STA_Parameter =  ImageParameter.STA.Parameter;
    elseif strcmp(ImageParameter.STA.Name,'DorisV4')
        g_strctParadigm.m_strctStatServerDesign.STA_Parameter = max(ImageParameter.StimulusSizePix_Y,ImageParameter.StimulusSizePix_X);
    end
end

g_strctParadigm.m_strctStatServerDesign.ConditionVisibility = ones(1,NumConditions);
%     end

fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);
%
% end

bSuccess  = true;
return;





