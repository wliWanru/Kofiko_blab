function strctTrial = fnSimpleStimPrepareTrial()

%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm
g_strctParadigm.m_bMovieInitialized  = false;

if isempty(g_strctParadigm.m_strctDesign)
    strctTrial = [];
    return;
end;

% if g_strctParadigm.m_bParameterSweep
%     [iNewStimulusIndex,iSelectedBlock] =  fnSelectNextStimulusUsingParameterSweep();
% else


index = fnSelectNextStimulus();

% end

% strctTrial.m_strctMicroStim = fnMicroStimThisTrial(iNewStimulusIndex_Image1,iNewStimulusIndex_Image2,iSelectedBlock);

%% Noise ?
% bOverlayNoise = g_strctParadigm.NoiseOverlayActive.Buffer(1,:,g_strctParadigm.NoiseOverlayActive.BufferIdx);
% if bOverlayNoise &&  g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns  > 0
%     strctTrial.m_bNoiseOverlay = true;
%     g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex=g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex+1;
%     if g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex >  g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns
%         g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex  = 1;
%     end
%     strctTrial.m_iNoiseIndex = g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex;
%     strctTrial.m_a2fNoisePattern = g_strctParadigm.m_a3fRandPatterns(:,:,strctTrial.m_iNoiseIndex);
% else
%     strctTrial.m_iNoiseIndex = 0;
%     strctTrial.m_bNoiseOverlay = false;
%     strctTrial.m_a2fNoisePattern =  [];
% end

%% Select new fixation and stimulus positions
% if g_strctParadigm.m_bRandFixPos
%     aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
%     g_strctParadigm.m_iRandFixCounter = g_strctParadigm.m_iRandFixCounter + 1;
%     if g_strctParadigm.m_iRandFixCounter >= g_strctParadigm.m_iRandFixCounterMax
%         g_strctParadigm.m_iRandFixCounter = 0;
%         g_strctParadigm.m_iRandFixCounterMax = g_strctParadigm.m_fRandFixPosMin + round(rand() * (g_strctParadigm.m_fRandFixPosMax-g_strctParadigm.m_fRandFixPosMin));
%         pt2iCenter = aiScreenSize(3:4)/2;
%         pt2iNewFixationSpot = 2*(rand(1,2)-0.5) * g_strctParadigm.m_fRandFixRadius + pt2iCenter;
%         % set a new random position for fixation point
%         fnTsSetVarParadigm('FixationSpotPix',pt2iNewFixationSpot);
%         fnParadigmToKofikoComm('SetFixationPosition',pt2iNewFixationSpot);
%         if g_strctParadigm.m_bRandFixSyncStimulus
%             fnTsSetVarParadigm('StimulusPos_Image1',[pt2iNewFixationSpot(1)-100 pt2iNewFixationSpot(2)]);
%             fnTsSetVarParadigm('StimulusPos_Image2',[pt2iNewFixationSpot(1)+100 pt2iNewFixationSpot(2)]);
%
%         end
%     end;
% end;


% Faster access than fnTsGetVar...
strctTrial.Image_index = index;

strctTrial.m_pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
strctTrial.m_pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);

strctTrial.m_BackgroundColor = squeeze(g_strctParadigm.BackgroundColor.Buffer(1,:,g_strctParadigm.BackgroundColor.BufferIdx));
strctTrial.m_FixationColor = squeeze(g_strctParadigm.FixationColor.Buffer(1,:,g_strctParadigm.FixationColor.BufferIdx));

strctTrial.m_FixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
strctTrial.m_GazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
strctTrial.m_StimulusSizePix_X = g_strctParadigm.StimulusSizePix_X.Buffer(1,:,g_strctParadigm.StimulusSizePix_X.BufferIdx);
strctTrial.m_StimulusSizePix_Y = g_strctParadigm.StimulusSizePix_Y.Buffer(1,:,g_strctParadigm.StimulusSizePix_Y.BufferIdx);

strctTrial.m_Contrast = g_strctParadigm.Contrast.Buffer(1,:,g_strctParadigm.Contrast.BufferIdx);
strctTrial.m_TF_HZ = g_strctParadigm.TF_HZ.Buffer(1,:,g_strctParadigm.TF_HZ.BufferIdx);
strctTrial.m_Orientation = g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx);
strctTrial.m_Depth = g_strctParadigm.Depth.Buffer(1,:,g_strctParadigm.Depth.BufferIdx);




% if strcmpi(strctTrial.m_strctMedia_Image1.m_strMediaType,'Movie') || strcmpi(strctTrial.m_strctMedia_Image1.m_strMediaType,'StereoMovie')
%     strctTrial.m_fStimulusON_MS = 0;
%     strctTrial.m_fStimulusOFF_MS = 0;
% else
strctTrial.m_fStimulusON_MS = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
strctTrial.m_fStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
% end
for i = 1:length(g_strctParadigm.Parameter_Name)
    if strcmp(g_strctParadigm.Parameter_Name{i},'TF_HZ') ...
            ||strcmp(g_strctParadigm.Parameter_Name{i},'Orientation')...
            ||strcmp(g_strctParadigm.Parameter_Name{i},'BackgroundColor')...
            ||strcmp(g_strctParadigm.Parameter_Name{i},'StimulusSizePix_X')...
            ||strcmp(g_strctParadigm.Parameter_Name{i},'StimulusSizePix_Y')

        
        eval(['strctTrial.m_' g_strctParadigm.Parameter_Name{i} ' =  g_strctParadigm.Parameter_Value{i}(index,:);']);
    end
    if strcmp(g_strctParadigm.Parameter_Name{i},'StimulusPos') ...
            eval(['strctTrial.m_pt2f' g_strctParadigm.Parameter_Name{i} ' =  g_strctParadigm.Parameter_Value{i}(index,:);']);
    end
end
% strctTrial.m_fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);
strctTrial.m_bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
strctTrial.m_iPhotoDiodeWindowPix = g_strctParadigm.m_iPhotoDiodeWindowPix;

return;




function index = fnSelectNextStimulus()
global g_strctParadigm
iNumMediaInBlock = length(g_strctParadigm.DisplayOrder);
g_strctParadigm.m_CurrentDisplayIndex = g_strctParadigm.m_CurrentDisplayIndex + 1;
if g_strctParadigm.m_CurrentDisplayIndex  > iNumMediaInBlock
    % Yey! We finished displaying a block!
    % Reset and increase counters accordingly!
    g_strctParadigm.m_CurrentDisplayIndex = 1;
    % Generate a new random indices for the media in this block!
    if g_strctParadigm.m_bRandom
        [fDummy,g_strctParadigm.DisplayOrder] = sort(rand(1,iNumMediaInBlock));
        [fDummy,g_strctParadigm.DisplayOrder] = sort(rand(1,iNumMediaInBlock));
        
    else
        g_strctParadigm.DisplayOrder = 1:iNumMediaInBlock;
    end
    
    g_strctParadigm.m_iNumTimesBlockShown = g_strctParadigm.m_iNumTimesBlockShown + 1;
    
    % How many times do we need to display this block ?
end
index = g_strctParadigm.DisplayOrder(g_strctParadigm.m_CurrentDisplayIndex);
return;

