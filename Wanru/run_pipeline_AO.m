raw_info.m_strDataRootFolder = '/Users/blab/同步空间/new_kofiko_wks/240201';
file = which('DataBrowser_AO');
[path junk] = fileparts(file);

raw_info.m_strConfigFolder = fullfile(path,'Config');
raw_info.m_strSession = '240201_124300_MaoDan';
raw_info.strMetaFolder = '/Users/blab/同步空间/new_kofiko_wks/ImageList';


fnPipelinePassiveFixation_AO(raw_info)

