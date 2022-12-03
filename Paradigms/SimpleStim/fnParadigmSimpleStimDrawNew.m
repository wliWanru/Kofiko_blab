function fnParadigmPassiveFixationDrawNew()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctParadigm

%% Get releavnt parameters
aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);

afBackgroundColor = squeeze(g_strctParadigm.BackgroundColor.Buffer(1,:,g_strctParadigm.BackgroundColor.BufferIdx));
fFixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
fGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
StimulusSizePix_X = g_strctParadigm.StimulusSizePix_X.Buffer(1,:,g_strctParadigm.StimulusSizePix_X.BufferIdx);
StimulusSizePix_Y = g_strctParadigm.StimulusSizePix_Y.Buffer(1,:,g_strctParadigm.StimulusSizePix_Y.BufferIdx);
FixationColor = squeeze(g_strctParadigm.FixationColor.Buffer(1,:,g_strctParadigm.FixationColor.BufferIdx));
Contrast = g_strctParadigm.Contrast.Buffer(1,:,g_strctParadigm.Contrast.BufferIdx);


fRotationAngle = 0;
bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
iPhotoDiodeWindowPix = g_strctParadigm.m_iPhotoDiodeWindowPix;

%% Clear screen
Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor);

%% Draw Stimulus
if ~isempty(g_strctParadigm.m_strctCurrentTrial) && g_strctParadigm.m_bStimulusDisplayed && isfield(g_strctParadigm.m_strctCurrentTrial,'Image_index') && ...
        g_strctParadigm.m_iMachineState ~= 6
    % Trial exist. Check state and draw either the image g_strctParadigm.m_strctCurrentTrial
    ImageKind = g_strctParadigm.m_strctDesign.CurrentParameter(g_strctParadigm.m_strctCurrentTrial.Image_index).ImageKind;
    if ~((ImageKind == 5)||(ImageKind == 7))
        fnDisplayMonocularImageLocally();
    elseif ImageKind == 5
        fnDisplayDotImageLocally();
    elseif ImageKind == 7
        fnDisplayNoiseImageLocally();
    end
end

%% Photodiode Crap
if bShowPhotodiodeRect && ~isempty(g_strctParadigm.m_strctCurrentTrial) && ...
        isfield(g_strctParadigm.m_strctCurrentTrial,'m_bIsMovie') && ~g_strctParadigm.m_strctCurrentTrial.m_bIsMovie
    bStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx) > 0;
    
    aiPhotoDiodeRect = g_strctPTB.m_fScale * [aiStimulusScreenSize(3)-iPhotoDiodeWindowPix ...
        aiStimulusScreenSize(4)-iPhotoDiodeWindowPix ...
        aiStimulusScreenSize(3) aiStimulusScreenSize(4)];
    
    if g_strctParadigm.m_bStimulusDisplayed
        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], aiPhotoDiodeRect);
    elseif ~g_strctParadigm.m_bStimulusDisplayed && bStimulusOFF_MS
        Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], aiPhotoDiodeRect);
    end
end

%% Draw Fixation Rect and Reward Rect and Stimulus Rect and RF
aiFixationRect = [pt2iFixationSpot-fFixationSizePix, pt2iFixationSpot+fFixationSizePix];
aiRewardRect = [pt2iFixationSpot-fGazeBoxPix,pt2iFixationSpot+fGazeBoxPix];
aiStimulusRect = [pt2fStimulusPos- [round(StimulusSizePix_X/2) round(StimulusSizePix_Y/2)], pt2fStimulusPos+[round(StimulusSizePix_X/2) round(StimulusSizePix_Y/2)]];

Screen('FillArc',g_strctPTB.m_hWindow,FixationColor, g_strctPTB.m_fScale * aiFixationRect,0,360);
Screen('FrameRect',g_strctPTB.m_hWindow,[255 0 0], g_strctPTB.m_fScale * aiRewardRect);
Screen('FrameRect',g_strctPTB.m_hWindow,[255 255 0], g_strctPTB.m_fScale * aiStimulusRect);
fscale = g_strctPTB.m_fScale;

if g_strctParadigm.m_bDrawRF && (~isempty(g_strctParadigm.m_ToDrawRF))
    for i = 1:size(g_strctParadigm.m_ToDrawRF,1)
        RFCenterX = g_strctParadigm.m_ToDrawRF(i,1); RFCenterY = g_strctParadigm.m_ToDrawRF(i,2);
        RFWidth = g_strctParadigm.m_ToDrawRF(i,3); RFLength = g_strctParadigm.m_ToDrawRF(i,4);
        RFCenterX = round(fscale*RFCenterX);    RFCenterY = round(fscale*RFCenterY); RFWidth = round(fscale*RFWidth/2)*2; RFLength = round(fscale*RFLength/2)*2;
        RFColor = g_strctParadigm.m_ToDrawRF(i,5); cc = [0 0 0]; cc(RFColor) = 255;
        Screen('FillRect',g_strctPTB.m_hWindow,cc,[-RFWidth/2 + RFCenterX -RFLength/2 + RFCenterY RFWidth/2 + RFCenterX RFLength/2 + RFCenterY]);
    end
end
%
% m_bDrawRF = get(g_strctParadigm.m_strctControllers.m_hDrawRF,'Value');
% RFCenterX = fnMyStr2Num(get(g_strctParadigm.m_strctControllers.CenterX_Edit,'String'));
% RFCenterY = fnMyStr2Num(get(g_strctParadigm.m_strctControllers.CenterY_Edit,'String'));
% RFWidth = fnMyStr2Num(get(g_strctParadigm.m_strctControllers.Width_Edit,'String'));
% RFLength = fnMyStr2Num(get(g_strctParadigm.m_strctControllers.Length_Edit,'String'));
% RFOrientation = fnMyStr2Num(get(g_strctParadigm.m_strctControllers.Orientation_Edit,'String'));
% fscale = g_strctPTB.m_fScale;
%
%
% if m_bDrawRF && ~isempty(RFCenterX) && ~isempty(RFCenterY) && ~isempty(RFWidth) && ~isempty(RFLength) && ~isempty(RFOrientation)
%     RFCenterX = round(fscale*RFCenterX);    RFCenterY = round(fscale*RFCenterY); RFWidth = round(fscale*RFWidth/2)*2; RFLength = round(fscale*RFLength/2)*2;
%     RFOrientation = -RFOrientation/180*pi;
%     RFCenter = [RFCenterX RFCenterY];
%
%     point(1,:) = [RFLength/2*cos(RFOrientation)+RFWidth/2*sin(RFOrientation) -RFLength/2*sin(RFOrientation)+RFWidth/2*cos(RFOrientation)] + RFCenter;
%     point(2,:) = [-RFLength/2*cos(RFOrientation)+RFWidth/2*sin(RFOrientation) RFLength/2*sin(RFOrientation)+RFWidth/2*cos(RFOrientation)] + RFCenter;
%     point(4,:) = [RFLength/2*cos(RFOrientation)-RFWidth/2*sin(RFOrientation) -RFLength/2*sin(RFOrientation)-RFWidth/2*cos(RFOrientation)] + RFCenter;
%     point(3,:) = [-RFLength/2*cos(RFOrientation)-RFWidth/2*sin(RFOrientation) RFLength/2*sin(RFOrientation)-RFWidth/2*cos(RFOrientation)] + RFCenter;
%
%     Screen('FramePoly',g_strctPTB.m_hWindow,[0 255 0],point,2);
% end



%% Juice Related drawing
fGazeTimeHighSec = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx) /1000;
fGazeTimeLowSec = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx) /1000;
fPositiveIncrement = g_strctParadigm.PositiveIncrement.Buffer(:,:,g_strctParadigm.PositiveIncrement.BufferIdx);
fMaxFixations = 100 / fPositiveIncrement;
fPercCorrect =  min(1,g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fGazeTimeSec = fGazeTimeLowSec + (fGazeTimeHighSec-fGazeTimeLowSec) * (1- g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fPerc = g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime / fGazeTimeSec;

fRadius = 50;
aiJuiceCircle = [10 g_strctPTB.m_aiRect(4)-fRadius-5, 10+fRadius g_strctPTB.m_aiRect(4)-5];
Screen('DrawArc',g_strctPTB.m_hWindow,[255 0 255], aiJuiceCircle,0,360);

aiJuiceCircle2 = [10+1 g_strctPTB.m_aiRect(4)-fRadius-5+1, 10+fRadius-1 g_strctPTB.m_aiRect(4)-5-1];
Screen('FillArc',g_strctPTB.m_hWindow,[128 0 128], aiJuiceCircle2,0,fPerc * 360);

% Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('%d%%',round(fPercCorrect*100)),...
%     10, g_strctPTB.m_aiRect(4)-fRadius/2-20+1, [0 255 0]);

%%
if g_strctParadigm.m_iMachineState == 0 && g_strctParadigm.m_bPausedDueToMotion
    Screen(g_strctPTB.m_hWindow,'DrawText', 'Paused due to monkey motion. Waiting for motion to stop...',...
        g_strctPTB.m_aiRect(1),g_strctPTB.m_aiRect(2)+20, [0 255 0]);
end

return;


function fnDisplayDotImageLocally()
global g_strctParadigm g_strctPTB
aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
Center = aiStimulusScreenSize(3:4)/2;

Index = g_strctParadigm.m_strctCurrentTrial.Image_index;
fscale = g_strctPTB.m_fScale;

YellowDotXY = g_strctParadigm.m_strctDesign.Yellow{g_strctParadigm.m_strctCurrentTrial.Image_index} * fscale;
RedDotXY = g_strctParadigm.m_strctDesign.Red{g_strctParadigm.m_strctCurrentTrial.Image_index} * fscale;
GreenDotXY = g_strctParadigm.m_strctDesign.Green{g_strctParadigm.m_strctCurrentTrial.Image_index} * fscale;
AllXY = g_strctParadigm.m_strctDesign.All{g_strctParadigm.m_strctCurrentTrial.Image_index} * fscale;
if ~isempty(YellowDotXY)
    Screen('DrawDots',g_strctPTB.m_hWindow,YellowDotXY,round(4*fscale),[255 255 0],Center,1);
end
if ~isempty(RedDotXY)
    Screen('DrawDots',g_strctPTB.m_hWindow,RedDotXY,round(4*fscale),[255 0 0],Center,1);
end
if ~isempty(GreenDotXY)
    Screen('DrawDots',g_strctPTB.m_hWindow,GreenDotXY,round(4*fscale),[0 255 0],Center,1);
end

function fnDisplayNoiseImageLocally()
global g_strctParadigm g_strctPTB

Index = g_strctParadigm.m_strctCurrentTrial.Image_index;
fscale = g_strctPTB.m_fScale;
%disparameter = g_strctDraw.strctDesign.DisplayParameter(:,Index);
StimCenter = g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
disparameter = g_strctParadigm.m_strctDesign.DisplayParameter(:,Index);
s1_pos = disparameter(1:2); s2_pos = disparameter(3:4); s1_color = disparameter(5); s2_color = disparameter(6);
s1_center = s1_pos' + StimCenter; s2_center = s2_pos' + StimCenter;
%s1_center = StimCenter; s2_center = StimCenter;

SquareSize = g_strctParadigm.m_strctDesign.Image_Size(2);

Screen('FillRect',g_strctPTB.m_hWindow,s1_color,round([s1_center(1)-SquareSize s1_center(2)-SquareSize s1_center(1)+SquareSize s1_center(2)+SquareSize]*fscale));
Screen('FillRect',g_strctPTB.m_hWindow,s2_color,round([s2_center(1)-SquareSize s2_center(2)-SquareSize s2_center(1)+SquareSize s2_center(2)+SquareSize]*fscale));



function fnDisplayMonocularImageLocally()
global g_strctParadigm g_strctPTB

Index = g_strctParadigm.m_strctCurrentTrial.Image_index;
fscale = g_strctPTB.m_fScale;

StimulusSizePix_X = g_strctParadigm.m_strctCurrentTrial.m_StimulusSizePix_X;
StimulusSizePix_Y = g_strctParadigm.m_strctCurrentTrial.m_StimulusSizePix_Y;

pt2fStimulusPos = g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
newpt2fStimulusPos = round(pt2fStimulusPos*fscale);
newSize_X = round(StimulusSizePix_X*fscale);
newSize_Y = round(StimulusSizePix_Y*fscale);
aiStimulusRect = [newpt2fStimulusPos(1)-round(newSize_X/2) newpt2fStimulusPos(2) - round(newSize_Y/2)...
    newpt2fStimulusPos(1)+round(newSize_X/2) newpt2fStimulusPos(2)+round(newSize_Y/2)];

fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_Orientation;
if (g_strctParadigm.m_strctDesign.CurrentParameter(Index).ImageKind == 6);
    if exist('hTexturePointer','var');
        Screen('Close',hTexturePointer);
    end
    NoiseImage = g_strctParadigm.m_strctDesign.Image{Index};
    hTexturePointer = Screen('MakeTexture',g_strctPTB.m_hWindow,uint8(NoiseImage));
else
    hTexturePointer = g_strctParadigm.m_strctDesign.Texture(Index);
end

TF_HZ = g_strctParadigm.m_strctCurrentTrial.m_TF_HZ;

switch g_strctParadigm.m_strctDesign.CurrentParameter(Index).ImageKind
    case 1
        OneCyclePixel = (g_strctParadigm.m_strctDesign.CurrentParameter(Index).PPD/g_strctParadigm.m_strctDesign.CurrentParameter(Index).SF_CyclePerDeg);
        PixelPerFrame =  OneCyclePixel*TF_HZ/60;
        
    case 2
        OneCyclePixel = g_strctParadigm.m_strctDesign.CurrentParameter(Index).StimulusSizePix_Y;
        PixelPerFrame =  OneCyclePixel*TF_HZ/60;
        
    case 3
        OneCyclePixel = 1;
        PixelPerFrame = 0;
    case 4
        OneCyclePixel = 1;
        PixelPerFrame = 0;
    case 6
        OneCyclePixel = 1;
        PixelPerFrame = 0;
end
Elapsetime = GetSecs - g_strctParadigm.m_strctCurrentTrial.m_fSentMessageTimer;

CurrentFrameIndex = Elapsetime*60; % This would block the server until the next flip.
offset = round(mod(PixelPerFrame * CurrentFrameIndex,OneCyclePixel));

%aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix_Image1, aiTextureSize1, pt2fStimulusPos_Image1);

if g_strctParadigm.m_bDisplayStimuliLocally
    
    if g_strctParadigm.m_strctDesign.CurrentParameter(Index).ImageKind == 6
        Screen('DrawTexture', g_strctPTB.m_hWindow, hTexturePointer,[],aiStimulusRect, fRotationAngle,0);
        
    else
        
        Screen('DrawTexture', g_strctPTB.m_hWindow, hTexturePointer,[0 offset 0+StimulusSizePix_X offset+StimulusSizePix_Y],aiStimulusRect, fRotationAngle);
    end
    
end


return;
%
%
%
%         function fnDisplayMonocularMovieLocally()
%             global g_strctParadigm g_strctPTB
%
%             if g_strctParadigm.m_bDisplayStimuliLocally
%                 fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
%                 hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
%                 pt2fStimulusPos_Image1 =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPosition_Image1;
%                 pt2fStimulusPos_Image2 =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPosition_Image2;
%
%                 aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
%                 aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos_Image1);
%                 aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos_Image2);
%
%                 fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);
%
%                 if ~g_strctParadigm.m_bMovieInitialized
%                     First time draw is called and a movie needs to be played...
%                     hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
%                     Screen('PlayMovie', g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer), 1,0,1);
%                     Screen('SetMovieTimeIndex',g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),0);
%                     g_strctParadigm.m_bMovieInitialized  = true;
%                     g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
%                     [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
%                     Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],aiStimulusRect, fRotationAngle);
%                     Screen('Close', hFrameTexture);
%                 else
%                     [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
%                     if hFrameTexture > 0
%                         Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],aiStimulusRect, fRotationAngle);
%                         Screen('Close', hFrameTexture);
%                     else
%                         No more frames to display....
%                         g_strctParadigm.m_bMovieInitialized  = false;
%                     end
%                 end
%
%             else
%                 if ~g_strctParadigm.m_bMovieInitialized
%                     g_strctParadigm.m_bMovieInitialized  = true;
%                     g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
%                 end
%
%                 Will not play movie, but just draw a text saying that this
%                 time has elapsed since movie onset...
%                 fTimeElapsed = GetSecs() - g_strctParadigm.m_fApproxMovieStartTS;
%                 pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
%                 Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Movie Playing %.1f Sec', fTimeElapsed),...
%                     pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
%             end
%
%             return;
%
%
%
%
%             function fnDisplayStereoImageLocally()
%                 global g_strctParadigm g_strctPTB
%
%                 pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
%                 fStimulusSizePix =g_strctParadigm.m_strctCurrentTrial.m_fStimulusSizePix;
%                 fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle;
%
%                 ahTexturePointers = g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_aiMediaToHandleIndexInBuffer;
%
%                 %
%
%                 if g_strctParadigm.m_bDisplayStimuliLocally
%                     if g_strctParadigm.m_strctCurrentTrial.m_bNoiseOverlay
%                         Overlay image with nosie...will be slower (!)
%                         a2fImage = g_strctParadigm.m_strctTexturesBuffer.m_acImages{ahTexturePointers(1)};
%                         if size(a2fImage,3) == 3
%                             Modify the image....
%                             I = a2fImage(:,:,1);
%                             a2bMask = I == 255;
%                             [a2fX,a2fY] = meshgrid(linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,2), size(a2fImage,2)),...
%                                 linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,1), size(a2fImage,1)));
%                             a2fNoiseResamples = fnFastInterp2(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern, a2fX(:),a2fY(:));
%                             I(a2bMask) = a2fNoiseResamples(a2bMask)*255;
%                             a2fImage = I;
%                         end
%                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
%                         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%
%                         hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage);
%                         Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
%                         Screen('Close',hImageID);
%                     else
%                         Default presentation mode of images...
%                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
%                         ahTexturePointersInBuffer = g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(ahTexturePointers);
%                         fnDrawStereoLocallyAux(ahTexturePointersInBuffer,aiTextureSize);
%
%                     end
%
%
%                 else
%                     Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Image %d (%s)',g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex,...
%                         g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_strName), pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
%                 end
%
%                 return;
%
%
%
%
%                 function fnDisplayStereoMovieLocally()
%                     global g_strctParadigm g_strctPTB
%
%                     if g_strctParadigm.m_bDisplayStimuliLocally
%                         fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
%                         hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
%                         pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
%                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
%                         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%                         fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);
%
%                         if ~g_strctParadigm.m_bMovieInitialized
%                             First time draw is called and a movie needs to be played...
%
%
%
%                             ahFrameTexture = zeros(1,2);
%                             for iHandleIter=1:2
%                                 hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(iHandleIter);
%                                 Screen('PlayMovie', g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer), 1,0,1);
%                                 Screen('SetMovieTimeIndex',g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),0);
%                                 [ahFrameTexture(iHandleIter), fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
%                             end
%
%                             g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
%                             aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
%                             fnDrawStereoLocallyAux(ahFrameTexture,aiTextureSize);
%                             Screen('Close', ahFrameTexture);
%
%                             g_strctParadigm.m_bMovieInitialized  = true;
%                         else
%                             ahFrameTexture = zeros(1,2);
%                             for iHandleIter=1:2
%                                 hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(iHandleIter);
%                                 [ahFrameTexture(iHandleIter), fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
%                             end
%                             if all(ahFrameTexture > 0)
%                                 fnDrawStereoLocallyAux(ahFrameTexture,aiTextureSize);
%                                 Screen('Close', ahFrameTexture);
%                             else
%                                 No more frames to display....
%                                 g_strctParadigm.m_bMovieInitialized  = false;
%                             end
%                         end
%
%                     else
%                         if ~g_strctParadigm.m_bMovieInitialized
%                             g_strctParadigm.m_bMovieInitialized  = true;
%                             g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
%                         end
%                         Will not play movie, but just draw a text saying that this
%                         time has elapsed since movie onset...
%                         fTimeElapsed = GetSecs() - g_strctParadigm.m_fApproxMovieStartTS;
%                         pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
%                         Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Movie Playing %.1f Sec', fTimeElapsed),...
%                             pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
%                     end
%                     return;
%
%
%
%
%
%
%                     function fnDrawStereoLocallyAux(ahTexturePointersInBuf,aiTextureSize)
%                         global g_strctParadigm  g_strctPTB
%                         Couple of ways to present stereo images...
%                         If they are gray scale, we can generate a red/blue presentation
%                         of them....
%
%                         pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
%                         fStimulusSizePix =g_strctParadigm.m_strctCurrentTrial.m_fStimulusSizePix;
%                         fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle;
%
%                         switch g_strctParadigm.m_strLocalStereoMode
%                             case 'Left Eye Only'
%                                 aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
%                                 aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
%                             case 'Right Eye Only'
%                                 aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
%                                 aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
%                             case 'Left & Side by Side (Small)'
%                                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
%                                 aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRect, fRotationAngle);
%
%                                 aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[-3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
%                                 Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
%
%                                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
%                                 aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
%                                 Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
%                             case 'Side by Side (Large)'
%                                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
%                                 aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[-fStimulusSizePix,+0]);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
%                                 Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
%
%                                         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointersInBuf(2))';
%                                 aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[fStimulusSizePix,+0]);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
%                                 Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
%                             case 'Left: Red, Right: Blue'
%                                 Slower. Need to generate textures on the
%                                 fly.....Let's assume also the the size of both images
%                                 is the same, otherwise this can crash....
%                                 aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%                                 a2fLeft = Screen('GetImage',ahTexturePointersInBuf(1));
%                                 a2fRight = Screen('GetImage',ahTexturePointersInBuf(2));
%
%
%                                 a3fNewImage = zeros([size(a2fLeft,1),size(a2fLeft,2),3]);
%                                 a3fNewImage(:,:,1) = a2fLeft(:,:,1);
%                                 a3fNewImage(:,:,3) = a2fRight(:,:,1);
%
%                                 hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3fNewImage);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
%                                 Screen('Close',hImageID);
%                             case 'Left: Blue, Right: Red'
%                                 Slower. Need to generate textures on the
%                                 fly.....Let's assume also the the size of both images
%                                 is the same, otherwise this can crash....
%                                 aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
%
%                                 a2fLeft = Screen('GetImage',ahTexturePointersInBuf(1));
%                                 a2fRight = Screen('GetImage',ahTexturePointersInBuf(2));
%
%                                 a3fNewImage = zeros([size(a2fLeft,1),size(a2fLeft,2),3]);
%                                 a3fNewImage(:,:,1) = a2fRight(:,:,1);
%                                 a3fNewImage(:,:,3) = a2fLeft(:,:,1);
%
%                                 hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3fNewImage);
%                                 Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
%                                 Screen('Close',hImageID);
%                         end
%
return;
