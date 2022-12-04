function iParadigmIndex = fnFindParadigmIndex(strctKofiko, strParadigmName)
iParadigmIndex = [];
for k=1:length(strctKofiko.g_astrctAllParadigms)
    if strcmp(strctKofiko.g_astrctAllParadigms{k}.m_strName, strParadigmName)
        iParadigmIndex = k;
        break;
    end;
end;
%assert(iParadigmIndex ~= -1);
return;


% ~~ strctKofiko.g_astrctAllParadigms{k}.m_strName
% k =
% 
%      1
% ans =
%     'Default'
% k =
% 
%      2
% ans =
% 
%     'Five Dot Eye Calibration'
% 
% 
% k =
% 
%      3
% 
% 
% ans =
% 
%     'Passive Fixation New'
% 
% 
% k =
% 
%      4
% 
% 
% ans =
% 
%     'fMRI Block Design New'
% 
% 
% k =
% 
%      5
% 
% 
% ans =
% 
%     'Touch Force Choice'
% 
% 
% k =
% 
%      6
% 
% 
% ans =
% 
%     'Two Image'
% 
% 
% k =
% 
%      7
% 
% 
% ans =
% 
%     'Simple Stim'
% ~~