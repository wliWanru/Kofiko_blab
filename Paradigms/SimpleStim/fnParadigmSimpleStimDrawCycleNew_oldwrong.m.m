function fnParadigmSimpleStimDrawCycleNew(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctPTB g_strctDraw g_strctServerCycle

fCurrTime = GetSecs();

if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand
        case 'ClearMemory'
            fnStimulusServerClearTextureMemory();
        case 'PauseButRecvCommands'
            Screen(g_strctPTB.m_hWindow,'FillRect',0);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            g_strctServerCycle.m_iMachineState = 0;
        case 'MakeImageList'
            Parameter = acInputFromKofiko{2};
            Screen(g_strctPTB.m_hWindow,'FillRect',0);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            
            fnStimulusServerClearTextureMemory();
            g_strctDraw.strctDesign = fnMakeImageAux(Parameter);
            
            fnStimulusServerToKofikoParadigm('AllImagesLoaded');
            g_strctServerCycle.m_iMachineState = 0;
        case 'ShowTrial'
            g_strctDraw.m_strctTrial = acInputFromKofiko{2};
            
            g_strctServerCycle.m_iMachineState = 1;
    end
end;

switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        fnDisplayMonocularImage();
    case 2
        fnWaitMonocularImageONPeriod();
    case 3
        fnWaitMonocularImageOFFPeriod();
    case 4
        fnWaitDotImageONPeriod();
        
end;

return;


function fnDisplayMonocularImage()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_BackgroundColor);
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_FixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_FixationSizePix];

Index = g_strctDraw.m_strctTrial.Image_index;


if ~(g_strctDraw.strctDesign.CurrentParameter(Index).ImageKind == 5)
    g_strctDraw.CurrentTexture = g_strctDraw.strctDesign.Texture(Index);
    
    StimCenter = g_strctDraw.m_strctTrial.m_pt2fStimulusPos;
    StimSize = [g_strctDraw.m_strctTrial.m_StimulusSizePix_X g_strctDraw.m_strctTrial.m_StimulusSizePix_Y];
    StimRect = [StimCenter(1) - round(StimSize(1)/2)+1 StimCenter(2) - round(StimSize(2)/2)+1 StimCenter(1) + round(StimSize(1)/2) StimCenter(2) + round(StimSize(2)/2)];
    TF_HZ = g_strctDraw.m_strctTrial.m_TF_HZ;
    switch g_strctDraw.strctDesign.CurrentParameter(Index).ImageKind
        case 1
            OneCyclePixel = (g_strctDraw.strctDesign.CurrentParameter(Index).PPD/g_strctDraw.strctDesign.CurrentParameter(Index).SF_CyclePerDeg);
            PixelPerFrame =  OneCyclePixel*TF_HZ/60;
            
        case 2
            OneCyclePixel = g_strctDraw.strctDesign.CurrentParameter(Index).StimulusSizePix_Y;
            PixelPerFrame =  OneCyclePixel*TF_HZ/60;
        case 3
            OneCyclePixel = 1;
            PixelPerFrame = 0;
        case 4
            OneCyclePixel = 1;
            PixelPerFrame = 0;
    end
    
    g_strctDraw.PixelPerFrame = PixelPerFrame;
    g_strctDraw.OneCyclePixel = OneCyclePixel;
    
    
    
    % if g_strctDraw.m_strctTrial.m_bNoiseOverlay
    
    %     if size(a2fImage,3) == 3
    %         % Modify the image....
    %         I = a2fImage(:,:,1);
    %         a2bMask = I == 255;
    %         [a2fX,a2fY] = meshgrid(linspace(1,  size(g_strctDraw.m_strctTrial.m_a2fNoisePattern,2), size(a2fImage,2)),...
    %             linspace(1,  size(g_strctDraw.m_strctTrial.m_a2fNoisePattern,1), size(a2fImage,1)));
    %         a2fNoiseResamples = fnFastInterp2(g_strctDraw.m_strctTrial.m_a2fNoisePattern, a2fX(:),a2fY(:));
    %         I(a2bMask) = a2fNoiseResamples(a2bMask)*255;
    %         a2fImage = I;
    %     end
    %
    %     hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage);
    offset = 0;
    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.CurrentTexture,[0 offset StimSize(1) offset+StimSize(2)],offset+StimRect,g_strctDraw.m_strctTrial.m_Orientation);
    %if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
    Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
        [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
    
    
    % Draw Fixation spot
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
    
    g_strctServerCycle.m_fLastFlipTime = magnet(g_strctPTB.m_hWindow); % This would block the server until the next flip.
    g_strctDraw.CurrentFrameIndex = 1; % This would block the server until the next flip.
    
    fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime,g_strctDraw.m_strctTrial.Image_index);
    g_strctServerCycle.m_iMachineState = 2;
else
    g_strctDraw.CurrentYellowDotXY = g_strctDraw.strctDesign.Yellow{Index};
    g_strctDraw.CurrentGreenDotXY = g_strctDraw.strctDesign.Green{Index};
    g_strctDraw.CurrentRedDotXY = g_strctDraw.strctDesign.Red{Index};
    Rect = Screen('Rect',g_strctPTB.m_hWindow);
    RectCenter = Rect(3:4)/2;
    if ~isempty(g_strctDraw.CurrentYellowDotXY)
        Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentYellowDotXY, 4, [255 255 0], RectCenter,1);
    end
    
    if ~isempty(g_strctDraw.CurrentGreenDotXY)
        Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentGreenDotXY, 4, [0 255 0], RectCenter,1);
    end
    
    if ~isempty(g_strctDraw.CurrentRedDotXY)
        Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentRedDotXY, 4, [255 0 0], RectCenter,1);
    end
    if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
            [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
    end
    
    % Draw Fixation spot
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
    
    g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
    g_strctDraw.CurrentFrameIndex = 1; % This would block the server until the next flip.
    
    fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime,g_strctDraw.m_strctTrial.Image_index);
    g_strctServerCycle.m_iMachineState = 4;
end




return;



function fnWaitMonocularImageONPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
Index = g_strctDraw.m_strctTrial.Image_index;

StimCenter = g_strctDraw.m_strctTrial.m_pt2fStimulusPos;
StimSize = [g_strctDraw.m_strctTrial.m_StimulusSizePix_X g_strctDraw.m_strctTrial.m_StimulusSizePix_Y];
StimRect = [StimCenter(1) - round(StimSize(1)/2)+1 StimCenter(2) - round(StimSize(2)/2)+1 StimCenter(1) + round(StimSize(1)/2) StimCenter(2) + round(StimSize(2)/2)];

aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_FixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_FixationSizePix];

Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctDraw.m_strctTrial.m_fStimulusON_MS/1e3
    % Turn stimulus off
    if g_strctDraw.m_strctTrial.m_fStimulusOFF_MS > 0
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_BackgroundColor);
        Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
        
        
        
        if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
            
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
        end
        
        g_strctServerCycle.m_fLastFlipTime = fnSimpleStimFlipWrapper(g_strctPTB.m_hWindow,0); % Block.
        fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
        g_strctServerCycle.m_iMachineState = 3;
    else
        fnStimulusServerToKofikoParadigm('TrialFinished');
        g_strctServerCycle.m_iMachineState = 0;
    end
else
    Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_BackgroundColor);
    g_strctDraw.CurrentFrameIndex = g_strctDraw.CurrentFrameIndex + 1; % This would block the server until the next flip.
    offset = round(mod(g_strctDraw.PixelPerFrame * g_strctDraw.CurrentFrameIndex,g_strctDraw.OneCyclePixel));
    
    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.CurrentTexture,[0 offset StimSize(1) offset+StimSize(2)],StimRect,g_strctDraw.m_strctTrial.m_Orientation);
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
    
    fLastFlipTime = fnSimpleStimFlipWrapper(g_strctPTB.m_hWindow,1, g_strctServerCycle.m_fLastFlipTime+ g_strctDraw.CurrentFrameIndex/g_strctPTB.m_iRefreshRate);  % Block (!)
    %g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
end

return;

function fnWaitDotImageONPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
Index = g_strctDraw.m_strctTrial.Image_index;
g_strctDraw.CurrentAllDotXY = g_strctDraw.strctDesign.All{Index};

aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_FixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_FixationSizePix];

Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctDraw.m_strctTrial.m_fStimulusON_MS/1e3
    % Turn stimulus off
    if g_strctDraw.m_strctTrial.m_fStimulusOFF_MS > 0
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_BackgroundColor);
        Rect = Screen('Rect',g_strctPTB.m_hWindow);
        RectCenter = Rect(3:4)/2;
        
        if ~isempty(g_strctDraw.CurrentYellowDotXY)
            Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentYellowDotXY, 4, [255 255 0], RectCenter,1);
        end
        
        if ~isempty(g_strctDraw.CurrentGreenDotXY)
            Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentGreenDotXY, 4, [255 255 0], RectCenter,1);
        end
        
        if ~isempty(g_strctDraw.CurrentRedDotXY)
            Screen('DrawDots', g_strctPTB.m_hWindow, g_strctDraw.CurrentRedDotXY, 4, [255 255 0], RectCenter,1);
        end
        
        Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
        
        
        
        if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
            
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
        end
        
        g_strctServerCycle.m_fLastFlipTime = fnSimpleStimFlipWrapper(g_strctPTB.m_hWindow,0); % Block.
        fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
        g_strctServerCycle.m_iMachineState = 3;
    else
        fnStimulusServerToKofikoParadigm('TrialFinished');
        g_strctServerCycle.m_iMachineState = 0;
    end
end

return;

function fnWaitMonocularImageOFFPeriod
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
        (g_strctDraw.m_strctTrial.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
    fnStimulusServerToKofikoParadigm('TrialFinished');
    g_strctServerCycle.m_iMachineState = 0;
    
end
return;

function fnDisplayMonocularMovie()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
hTexturePointer = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);

% Start playing movie
Screen('PlayMovie', g_strctDraw.m_ahHandles(hTexturePointer), 1,0,1);
Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(hTexturePointer),0);
g_strctDraw.m_fMovieOnset = GetSecs();
% Show first frame and go to state 5

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];

aiTextureSize = g_strctDraw.m_a2iTextureSize(:, hTexturePointer);
g_strctDraw.m_aiStimulusRect = fnComputeStimulusRect(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSize, ...
    g_strctDraw.m_strctTrial.m_pt2fStimulusPos);


[hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, ...
    g_strctDraw.m_ahHandles(hTexturePointer),1);

% Assume there is at least one frame in this movie... otherwise this
% will crash...

Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);


if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
    Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
        [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
end


fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
Screen('Close', hFrameTexture);
fnStimulusServerToKofikoParadigm('FlipON',g_strctDraw.m_fMovieOnset,g_strctDraw.m_strctTrial.m_iStimulusIndex_Image1);

iApproxNumFrames = g_strctDraw.m_aiApproxNumFrames(hTexturePointer);
g_strctDraw.m_iFrameCounter = 1;
g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,iApproxNumFrames);
g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time

g_strctServerCycle.m_iMachineState = 5;
return;



% function fnKeepPlayingMonocularMovie()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
%
% % Movie is playing... Fetch frame and display it
% hTexturePointer = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
%
% [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, ...
%     g_strctDraw.m_ahHandles(hTexturePointer),1);
%
% if hFrameTexture == -1
%     % End of movie
%     % Flip background color and fixation spot for one frame to
%     % clear the last frame
%
%     Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%     aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%         g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%     Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%     fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);  % Block (!)
%
%     g_strctDraw.m_a2fFrameFlipTS = g_strctDraw.m_a2fFrameFlipTS(:,1:g_strctDraw.m_iFrameCounter-1);
%     fnStimulusServerToKofikoParadigm('TrialFinished',g_strctDraw.m_a2fFrameFlipTS,fLastFlipTime );
%     g_strctServerCycle.m_iMachineState = 0;
% else
%     % Still have frames
%     %     if fTimeToFlip == g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter)
%     %         % This frame HAS been displayed yet.
%     %         % Don't do anything. (it should still be on the screen...)
%     %         Screen('Close', hFrameTexture);
%     %
%     %     else
%     Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%     aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%         g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%     Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
%     Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%
%     if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
%         Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
%             [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
%     end
%
%
%     fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow, g_strctDraw.m_fMovieOnset+fTimeToFlip);  % Block (!)
%     Screen('Close', hFrameTexture);
%
%     g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter + 1;
%     g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
%     g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time
%     %     end
% end
% return;
%
%
%
%
% function fnDisplayStereoImage()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
%
%
% aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%     g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
% ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer; % LeftEye, RightEye
%
% aiTextureSizeLeft = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(1));
% aiTextureSizeRight = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(2));
% aiStimulusRectLeft = fnComputeStimulusRect(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSizeLeft, g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
% aiStimulusRectRight = fnComputeStimulusRect(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSizeRight, g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
% a2iStimuliRect =[ aiStimulusRectLeft;aiStimulusRectRight];
% %{
% if g_strctDraw.m_strctTrial.m_bNoiseOverlay
%     % NOT supported under stereo....
% %}
%
%
% for iBuffer=0:1
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
%
%
%     Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
%
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
%
%     Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(1+iBuffer)),[],a2iStimuliRect(iBuffer+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);
%
%     if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
%         if iBuffer == 0
%             Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
%                 [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                 g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%         else
%             Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
%                 [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
%                 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                 g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%
%         end
%
%         Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
%             [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
%     end
%
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
%
%     % Draw Fixation spot
%     Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
% end
% fprintf('\n');
% g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
% fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime,g_strctDraw.m_strctTrial.m_iStimulusIndex_Image1);
% g_strctServerCycle.m_iMachineState = 7;
% return;
%
% function fnWaitStereoImageONPeriod()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
%
% if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctDraw.m_strctTrial.m_fStimulusON_MS/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
%     % Turn stimulus off
%     if g_strctDraw.m_strctTrial.m_fStimulusOFF_MS > 0
%
%         for iBufferIter=0:1
%             Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
%
%             Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%
%             aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%                 g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%             Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%
%             if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
%
%                 Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
%                     [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                     g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                     g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
%             end
%         end
%         g_strctServerCycle.m_fLastFlipTime = fnSimpleStimFlipWrapper( g_strctPTB.m_hWindow,0); % Block.
%         fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
%
%         g_strctServerCycle.m_iMachineState = 8;
%     else
%         fnStimulusServerToKofikoParadigm('TrialFinished');
%         g_strctServerCycle.m_iMachineState = 0;
%     end
% end
% return;
%
%
% function fnWaitStereoImageOFFPeriod()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
%
% if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
%         (g_strctDraw.m_strctTrial.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
%     fnStimulusServerToKofikoParadigm('TrialFinished');
%     g_strctServerCycle.m_iMachineState = 0;
% end
%
% return;
%
%
%
%
% function  fnDisplayStereoMovie()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
% ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
%
% % Start playing movie
% Screen('PlayMovie', g_strctDraw.m_ahHandles(ahTexturePointers(1)), 1,0,1);
% Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(ahTexturePointers(1)),0);
% if ahTexturePointers(1) ~= ahTexturePointers(2)
%     Screen('PlayMovie', g_strctDraw.m_ahHandles(ahTexturePointers(2)), 1,0,1);
%     Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(ahTexturePointers(2)),0);
% end
% g_strctDraw.m_fMovieOnset = GetSecs();
% % Show first frame and go to state 10
% for iBufferIter=0:1
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
%
%     Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%     aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%         g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%     aiTextureSize = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(iBufferIter+1));
%     g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:) = fnComputeStimulusRect(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSize,g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
%     [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(iBufferIter+1)),1);
%     % Assume there is at least one frame in this movie... otherwise this
%     % will crash...
%     Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);
%     Screen('Close', hFrameTexture);
%     % Draw fixation spot
%     Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%
%
%     if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
%         if iBufferIter == 0
%             Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
%                 [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                 g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%         else
%             Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
%                 [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
%                 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                 g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%
%         end
%
%         Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
%             [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%             g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
%     end
%
% end
%
%
%
%
%
%
%
% fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
%
% fnStimulusServerToKofikoParadigm('FlipON',g_strctDraw.m_fMovieOnset,g_strctDraw.m_strctTrial.m_iStimulusIndex_Image1);
%
% iApproxNumFrames = min(g_strctDraw.m_aiApproxNumFrames(ahTexturePointers)); % Shorter movie set the length!
% g_strctDraw.m_iFrameCounter = 1;
% g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,iApproxNumFrames);
% g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
% g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time
%
%
% g_strctServerCycle.m_iMachineState = 10;
% return;
%
%
%
%
% function fnKeepPlayingStereoMovie()
% global g_strctDraw g_strctPTB g_strctServerCycle
% fCurrTime  = GetSecs();
%
% % Movie is playing... Fetch frame and display it
% ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
% for iBufferIter=0:1
%     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
%
%     [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(iBufferIter+1)),1);
%
%     if hFrameTexture == -1
%         % End of movie
%         % Flip background color and fixation spot for one frame to
%         % clear the last frame
%         for iIter=0:1
%             Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iIter);
%             Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%             aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%                 g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%             Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%         end
%         fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);  % Block (!)
%         g_strctDraw.m_a2fFrameFlipTS = g_strctDraw.m_a2fFrameFlipTS(:,1:g_strctDraw.m_iFrameCounter-1);
%         fnStimulusServerToKofikoParadigm('TrialFinished',g_strctDraw.m_a2fFrameFlipTS,fLastFlipTime );
%         g_strctServerCycle.m_iMachineState = 0;
%         return;
%     else
%         % Still have frames
%         %         if fTimeToFlip == g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter)
%         %             % This frame HAS been displayed yet.
%         %             % Don't do anything. (it should still be on the screen...)
%         %             Screen('Close', hFrameTexture);
%         %         else
%         Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
%
%         Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
%         aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
%             g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
%
%         Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);
%         Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
%         Screen('Close', hFrameTexture);
%
%
%         if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
%             if iBufferIter == 0
%                 Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
%                     [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                     g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                     g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%             else
%                 Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
%                     [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
%                     g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
%                     g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
%
%             end
%
%             Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
%                 [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
%                 g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
%         end
%
%
%         %         end
%     end
% end
%
% fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow, g_strctDraw.m_fMovieOnset+fTimeToFlip);  % Block (!)
%
% g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter + 1;
% g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
% g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time
%
% return;

function fFlipTime = fnSimpleStimFlipWrapper(hWindow,flag,varargin)
% A wrapper function to Screen('Flip')
% used to draw a small rectangle (either black or white) just prior to the flip
% to obtain the most accurate time stamp from a photodiode attached to the
% screen....
% This is to adjust for LCD lag time (which can range between 10-20 ms...)
%
Rect = Screen('Rect', hWindow);

global g_bPhotoDiodeToggle
iRectSizePix = 50;
Screen('FillRect', hWindow, [0 0 0],[Rect(3)-iRectSizePix*2+1 Rect(4)-iRectSizePix*2+1 Rect(3) Rect(4)]);
Screen('FillRect', hWindow, [0 0 0],[0 0 iRectSizePix*2 iRectSizePix*2]);

if flag == 1
    % Draw the small white rectangle
    Screen('FillRect', hWindow, [255 255 255],[Rect(3)-iRectSizePix+1 Rect(4)-iRectSizePix+1 Rect(3) Rect(4)]);
    Screen('FillRect', hWindow, [255 255 255],[0 0 iRectSizePix iRectSizePix]);
    
    g_bPhotoDiodeToggle = true;
else
    % Draw the small black rectangle
    Screen('FillRect', hWindow, [0 0 0],[Rect(3)-iRectSizePix+1 Rect(4)-iRectSizePix+1 Rect(3) Rect(4)]);
    Screen('FillRect', hWindow, [0 0 0],[0 0 iRectSizePix iRectSizePix]);
    
    g_bPhotoDiodeToggle = false;
    
end

fFlipTime = Screen('Flip', hWindow, varargin{:});

return;
