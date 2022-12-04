function [strSpecialAnalysisFunc, strDisplayFunction, strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strImageListUsed)
% ~~ what's specificAnalysis???
% ~~ GOAL is to find if there's any of the following 
%     '\\192.168.50.93\StimulusSet\Monkey_Bodyparts\StandardFOB_v2.txt'
%     '\\192.168.50.93\StimulusSet\Monkey_Bodyparts\imlist.txt'
%     '\\192.168.50.93\StimulusSet\StandardFaceLocalizer\V6\StandardFOB_v6.xml'
%     '\\192.168.50.93\StimulusSet\Sinha_Exp\Sinha_v5_FOB_Blocks.xml'
%     '\\192.168.50.93\StimulusSet\cartoon\CartoonList.xml'
%     '\\192.168.50.93\StimulusSet\Sinha_Exp\Sinha_v4_FOB_Blocks.xml'
%     '\\192.168.50.93\StimulusSet\Sinha_Exp\Sinha_v3_FOB.xml'
%     '\\192.168.50.93\StimulusSet\ReverseCorrelation\ReverseCorrelationFrontal.xml'
% ~~ that matches the strImageListUsed (input arg)
% ~~ if match, returns the
%    strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strAnalysisScript and 
%    strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strDisplayScript;


strctSpecialAnalysis = [];
strSpecialAnalysisFunc = '';
strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;
if ~isfield(strctConfig,'m_acSpecificAnalysis')
    iNumSpecificAnalysisAvail = 0;
else
    iNumSpecificAnalysisAvail = length(strctConfig.m_acSpecificAnalysis);    
end

if ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end


for iSpecialIter=1:iNumSpecificAnalysisAvail
    acFieldNames = fieldnames(strctConfig.m_acSpecificAnalysis{iSpecialIter});  % 'attribute' names
    %   6×1 cell array
    %     {'m_bActive'               }
    %     {'m_strAnalysisDescription'}
    %     {'m_strAnalysisScript'     }
    %     {'m_strDesignName'         }
    %     {'m_strDesignName2'        }
    %     {'m_strDisplayScript'      }

    iNumSubFields = length(acFieldNames);
    for k=1:iNumSubFields
        % ~~ Compare first N characters of strings or character vectors ignoring case
        % ~~ here, m_strDesignName and m_strDesignName2 both generate true

        if strncmpi(acFieldNames{k},'m_strDesignName',length('m_strDesignName'))
            strDesignName = getfield(strctConfig.m_acSpecificAnalysis{iSpecialIter},acFieldNames{k})
            if strcmpi(strImageListUsed, strDesignName)
                strctSpecialAnalysis = strctConfig.m_acSpecificAnalysis{iSpecialIter}; 
                strSpecialAnalysisFunc = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strAnalysisScript;
                strDisplayFunction = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strDisplayScript;
                return;
            end
        end
    end
end
return; 
