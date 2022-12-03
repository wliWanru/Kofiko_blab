function strctDesign = fnMakeImageAux(ImageParameter)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
% [strPath, strFile, strExt] = fileparts(strDesignFile);
global g_strctPTB
if ImageParameter.ImageKind == 5
    Rmax = 512; % Big enough
    ndots = 5000;
    xy = (2*rand(ndots,2)-1)*Rmax;
end

rand('seed',1);
for i = 1:length(ImageParameter.Parameter_Value{1}) % How many images we are going to show
    for j = 1:length(ImageParameter.Parameter_Name) % How many Parameter
        if strcmp(ImageParameter.Parameter_Name{j},'SF_CyclePerDeg')...
                ||strcmp(ImageParameter.Parameter_Name{j},'StimulusSizePix_X')...
                ||strcmp(ImageParameter.Parameter_Name{j},'StimulusSizePix_Y')...
                ||strcmp(ImageParameter.Parameter_Name{j},'Contrast')...
                ||strcmp(ImageParameter.Parameter_Name{j},'SurfaceColor')...
                ||strcmp(ImageParameter.Parameter_Name{j}, 'Depth')
            eval(['ImageParameter.' ImageParameter.Parameter_Name{j} '=' num2str(ImageParameter.Parameter_Value{j}(i)) ';']);
        end
        
        if strcmp(ImageParameter.Parameter_Name{j},'StimulusPos') ...
                eval(['ImageParameter.' ImageParameter.Parameter_Name{j} ' =  ImageParameter.Parameter_Value{j}(i,:);']);
        end
    end
    spatialfrequency = ImageParameter.PPD/ImageParameter.SF_CyclePerDeg;
    switch ImageParameter.ImageKind
        case 1 % Sine Grating;
            [x y] = meshgrid(1:ImageParameter.StimulusSizePix_X,1:ceil((ImageParameter.StimulusSizePix_Y+spatialfrequency)));
            I = sin(y/spatialfrequency*2*pi);
            strctDesign.Image{i} = uint8(GammaCorrection(I/2*255*ImageParameter.Contrast+128));
            
        case 2 % Bar
            I = zeros(2*ImageParameter.StimulusSizePix_Y,ImageParameter.StimulusSizePix_X);
            I(ImageParameter.StimulusSizePix_Y-ImageParameter.BarWidth+1:ImageParameter.StimulusSizePix_Y,:) = 1;
            strctDesign.Image{i} = uint8(GammaCorrection(I*127+ 128));
        case 3 % Solid Color flicker
            I = uint8(ImageParameter.SurfaceColor*ones(ImageParameter.StimulusSizePix_Y,ImageParameter.StimulusSizePix_X));
            strctDesign.Image{i} = I;
        case 4 % Sationary Bar
            I = zeros(2*ImageParameter.StimulusSizePix_Y,ImageParameter.StimulusSizePix_X);
            I(ImageParameter.StimulusSizePix_Y-ImageParameter.BarWidth+1:ImageParameter.StimulusSizePix_Y,:) = 1;
            strctDesign.Image{i} = uint8(I*127+ 128);
        case 5 % Random Dot Stationanry (For Stereo)
            Position = ImageParameter.StimulusPos;
            theta = ImageParameter.Orientation*pi/180;
            da = ImageParameter.StimulusSizePix_X;
            db = ImageParameter.StimulusSizePix_Y;
            Depth = ImageParameter.Depth;
            dist1 = abs(xy(:,2) - tan(theta)*xy(:,1)-((Position(2)-tan(theta)*Position(1))))/sqrt(1+tan(theta)^2);
            dist2 = abs(xy(:,2) - tan(theta+pi/2)*xy(:,1)-((Position(2)-tan(theta+pi/2)*Position(1))))/sqrt(1+tan(theta+pi/2)^2);
            StereoIndex = dist1 < db/2 & dist2 <da/2;
            YellowDotxy = (xy(~(StereoIndex),:))';
            RedDotxy = (xy(StereoIndex,:))' - repmat([Depth;0],1,length(find(StereoIndex==1)));
            GreenDotxy = (xy(StereoIndex,:))' + repmat([Depth;0],1,length(find(StereoIndex==1)));;
            strctDesign.Yellow{i} = YellowDotxy;
            strctDesign.Red{i}= RedDotxy;
            strctDesign.Green{i} = GreenDotxy;
            strctDesign.All{i} = xy';
            strctDesign.Image{i} = 0; 
        case 6
            if isfield(ImageParameter,'STA') && isfield(ImageParameter.STA,'Parameter')
                strctDesign.Image{i} = (rand(16,16)>ImageParameter.STA.Parameter)*255;
            else %Default 95% White
                strctDesign.Image{i} = (rand(16,16)>0.95)*255;
            end
        case 7
            a1 = [0 0]; a2 = [0 0];
            StimSize = max(ImageParameter.StimulusSizePix_X,ImageParameter.StimulusSizePix_Y);
            StimSize = 16 * round(StimSize/16);
            SquareSize = StimSize/16;
            
            while(abs(a1(1)-a2(1))< SquareSize || abs(a1(2)-a2(2))<SquareSize)
            a1 = round((rand(1,2)-0.5) * (StimSize-SquareSize)+SquareSize);
            a2 = round((rand(1,2)-0.5) * (StimSize-SquareSize)+SquareSize);
            end
            if rand > 0.5
                color = [255 255];
            else
                color = [255 0];
            end
            %%Debug
            %a1 = [0 0]; a2 = [100 100];

            strctDesign.DisplayParameter(:,i) = [a1 a2 color]';
            strctDesign.Image_Size = [StimSize SquareSize];
            strctDesign.Image{i} = 0;
            

    end
    Temp = ImageParameter;
    Temp = rmfield(Temp,{'Parameter_Name','Parameter_Value'});
    strctDesign.CurrentParameter(i) = Temp;
    
end


if ImageParameter.ImageKind < 5
    for i = 1:length(strctDesign.Image)
        
        strctDesign.Texture(i) = Screen('MakeTexture', g_strctPTB.m_hWindow,strctDesign.Image{i});
        
    end
end






%
% if strcmpi(strExt,'.txt')
%     % convert to XML and load....
%     [strTempXmlFile] = fnConvertOldStyleImageListToNewStyleImageList(strDesignFile);
%     strctDesign = fnReadNewStyleDesign(strTempXmlFile);
% else
%     strctDesign = fnReadNewStyleDesign(strDesignFile);
% end
%
% return;
%
% function strctDesign = fnReadNewStyleDesign(strDesignXML)
% global g_strctParadigm
% % Parse XML...
%  [strctDesign, bStereoRequired] = fnParsePassiveFixationDesignMediaFiles(strDesignXML, true, true);
%  if isempty(strctDesign)
%      return;
%  end;
%  % Design contain array of media (images, movies, stereo images, stereo
%  % movies, multiple images, etc...)
%  % Each media can contain more than one file that is needed.
%  % The next step is to understand exactly which files are needed to be
%  % loaded and to keep an indexing system from media to loaded files (or PTB
%  % textures).
%  [acFileNames, acMediaToHandleIndex] = fnMediaToFilesToLoad(strctDesign.m_astrctMedia);
%
% % Update media fields with infomration
% for iMediaIter=1:length(strctDesign.m_astrctMedia)
%     strctDesign.m_astrctMedia(iMediaIter).m_aiMediaToHandleIndexInBuffer = acMediaToHandleIndex{iMediaIter};
% end
%
% fnParadigmToKofikoComm('ClearMessageBuffer');
% % Instruct stimulus server to load the required files.
% % bForceStereoForMonocularLists = fnTsGetVar(g_strctParadigm,'ForceStereoOnMonocularLists') > 0;
% %
% % if bStereoRequired || bForceStereoForMonocularLists
% %     fnParadigmToStimulusServer('SetStereoMonoMode','Stereo');
% % else
% %     fnParadigmToStimulusServer('SetStereoMonoMode','Mono');
% % end
%
% fnParadigmToStimulusServer('ForceMessage','LoadImageList',acFileNames);
% % Now, load these files locally as well...
% fnParadigmPassiveCleanTextureMemory();
%
%   bShowWhileLoading =  isfield(g_strctParadigm,'m_bShowWhileLoading') && g_strctParadigm.m_bShowWhileLoading ;
%
% [g_strctParadigm.m_strctTexturesBuffer.m_ahHandles,...
%     g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize,...
%     g_strctParadigm.m_strctTexturesBuffer.m_abIsMovie,...
%     g_strctParadigm.m_strctTexturesBuffer.m_aiApproxNumFrames,...
%     g_strctParadigm.m_strctTexturesBuffer.m_afMovieLengthSec,...
%     g_strctParadigm.m_strctTexturesBuffer.m_acImages] = fnInitializeTexturesAux(acFileNames,bShowWhileLoading,false);
%
% bTimeout = fnParadigmToKofikoComm('BlockUntilMessage','LoadedImage', length(acFileNames),10); % 10 sec timeout
% if bTimeout
%         fnParadigmToKofikoComm('DisplayMessage','Stimulus server not finished loading!!!!');
% end
% return;
%
%
% function [acFilesNames, acMediaToHandleIndex] = fnMediaToFilesToLoad(astrctMedia)
% acAllFiles = cell(0);
% iNumMedia = length(astrctMedia);
% for k=1:iNumMedia
%     acAllFiles = [acAllFiles, astrctMedia(k).m_acFileNames];
% end
% acFilesNames = unique(acAllFiles);
%
% acMediaToHandleIndex= cell(1,iNumMedia);
% for k=1:iNumMedia
%     for j=1:length(astrctMedia(k).m_acFileNames)
%         acMediaToHandleIndex{k}(j) = fnFindString( acFilesNames,  astrctMedia(k).m_acFileNames{j});
%     end
% end
% return;
%
%
%
% function strXMLfile = fnConvertOldStyleImageListToNewStyleImageList(strDesignFile)
% [acFileNames ] = fnReadImageList(strDesignFile);
% iNumMediaFiles = length(acFileNames);
% % Try to load the corresponding category file
% acMediaAttributes = cell(1, iNumMediaFiles);
%
% [strPath, strFile, strExt] = fileparts(strDesignFile);
% strCatFile = [strPath,'\',strFile,'_Cat.mat'];
% if exist(strCatFile,'file')
%     Tmp = load(strCatFile);
%     a2bStimulusToCondition = Tmp.a2bStimulusCategory > 0;
%     acConditionNames = Tmp.acCatNames;
%
%     if size(a2bStimulusToCondition,1) ~= iNumMediaFiles || size(a2bStimulusToCondition,2) ~= length(acConditionNames)
%         fnParadigmToKofikoComm('DisplayMessage','Category file does not match list!');
%         acConditionNames = [];
%     end;
%      abVisibleConditions = ones(1, length(  acConditionNames)) > 0;
%     for iMediaIter=1:iNumMediaFiles
%          acMediaAttributes{iMediaIter} = acConditionNames(a2bStimulusToCondition(iMediaIter,:));
%     end
% else
%    acConditionNames = [];
%    abVisibleConditions = [];
% end;
%
% % Now that we have file names and conditions, generate the xml...
% [strPath, strFile] = fileparts(strDesignFile);
% strXMLfile = [tempdir,strFile,'.xml'];
% hFileID = fopen(strXMLfile,'w+');
% fprintf(hFileID,'<Config>\n\n');
% fprintf(hFileID,'    <Media>\n');
% for iFileIter=1:length(acFileNames)
%
%     strAttributes = '';
%      if ~isempty(acMediaAttributes{iFileIter} )
%          iNumAttributes = length(acMediaAttributes{iFileIter});
%          if iNumAttributes == 1
%              strAttributes = acMediaAttributes{iFileIter}{1};
%          else
%             for iAttrIter=1:iNumAttributes
%                 strAttributes = [strAttributes,';',acMediaAttributes{iFileIter}{iAttrIter}];
%             end
%          end
%
%      end
%
%     [strDummy, strName] = fileparts(acFileNames{iFileIter});
%      fprintf(hFileID,'        <Image Name = "%s" FileName = "%s"  Attr = "%s"> </Image>\n',strName,acFileNames{iFileIter},strAttributes);
% end
%
% fprintf(hFileID,'\n    </Media>\n');
%  fprintf(hFileID,'    <Conditions>\n');
%  iNumConditions = length(acConditionNames);
%  for iCondIter=1:iNumConditions
%      fprintf(hFileID,'        <Condition Name = "%s" ValidAttributes = "%s" DefaultVisibility = "1"> </Condition>\n',acConditionNames{iCondIter},acConditionNames{iCondIter});
%  end
%   fprintf(hFileID,'    </Conditions>\n');
%
%
%
% fprintf(hFileID,'    <StatServer\n');
% fprintf(hFileID,'        NumTrialsInCircularBuffer = "200"\n');
% fprintf(hFileID,'        Pre_TimeSec = "0.5"\n');
% fprintf(hFileID,'        Post_TimeSec = "0.5"\n');
% fprintf(hFileID,'    > </StatServer>   \n');
%
% fprintf(hFileID,'</Config>\n\n');
% fclose(hFileID);
% return;
%
%
%
%
%
%\

function im = GammaCorrection(im)
im = round((double(im)/255).^(1/1.77)*255);