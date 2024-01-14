% function [] = ao_initialize_merged_file()
% 
% %% -- keep important info from ao
% ao.t_TimeBegin = times_record(1, 2);
% ao.t_TimeEnd = times_record(2, 1);
% 
% %% --------- should check all sampling rate and so on
% if length(unique(ao_attributes.RAW))
% ao.RAW.att_SampleRate = 
