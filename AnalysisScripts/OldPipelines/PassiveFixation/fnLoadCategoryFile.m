function [a2bStimulusCategory,acCatNames,strImageListDescrip] = fnLoadCategoryFile(strImageListUsed)
[strPath,strFile] = fileparts(strImageListUsed);
strCatFile = [strFile, '_Cat.mat'];  % ~~ why use this instead of assign imlist_Cat in the config? 
if ~exist(strCatFile,'file') && exist([strPath,filesep,strCatFile],'file')
	strCatFile =  [strPath,filesep,strCatFile];
end

if exist(strCatFile,'file')
    strctTmp = load(strCatFile);
    % ~~     a2bStimulusCategory: [96×6 logical]
    % ~~     acCatNames: {'Faces'  'Bodies'  'Fruits'  'Gadgets'  'Hands'  'Scrambles'}
    % ~~     strImageListDescrip: 'FOB'


    a2bStimulusCategory = strctTmp.a2bStimulusCategory;
    acCatNames = strctTmp.acCatNames;

    % ~~ if no field strImageListDescrip, the descrip would be strFile
    if isfield(strctTmp,'strImageListDescrip')
        strImageListDescrip = strctTmp.strImageListDescrip;
    else
        strImageListDescrip = strFile;  
    end
    return;
end

% ~~ if exist(strCatFile,'file') is false: 
% No category file was found. Treat each stimulus as a category
fnWorkerLog('Warning, no category file was found for image %s',strImageListUsed);

a2bStimulusCategory = [];
acCatNames = [];
strImageListDescrip = [];
return;
