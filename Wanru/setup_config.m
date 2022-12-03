%% for windows
if ispc
    data_dir_pb = 'G:\data\tool_data\KofikoPB\trunk'; 
    data_raw_dir = 'G:\data\tool_data\raw_eph\150924\RAW'; 
    addpath(genpath(pwd()));
    
    DataBrowser;
elseif ismac
    %% for mac
    
    data_dir_pb = '/Users/liwanru/sync/codes/open_codes/Kofiko_blab'; 
    data_raw_dir = '/Users/liwanru/sync/codes/open_codes/tool_data/raw_eph/150924/raw'; 
    addpath(genpath(data_dir_pb));
    
    DataBrowser;

    % --- RAW DATA-add session-G:\data\tool_data\raw_eph\150924\RAW\150924_155226_Rocco.mat
    % --- Spike Sorting-Offline spike sorting
    
end
