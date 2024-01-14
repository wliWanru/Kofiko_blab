addpath('read_ao_mat');



data_dir = 'K:\data\project_data\ephys\240111';

data_fnames = cellfun(@(x) fullfile(data_dir, sprintf('F240111-%04d', x)), num2cell(2), 'UniformOutput', false);
n_record_files = length(data_fnames);

idx_record_ch = 3; 

ch_name_SEG = sprintf('CSEG_%03d', idx_record_ch);


% Read and store all files in a structure
all_files = struct();
for idx = 1:n_record_files
    all_files(idx).data = load(data_fnames{idx});
end


strSessionName = '240111_111111_TuTu'; 
strRawFolder = data_dir; 






%% 
interval_tbl = read_interval_txt(fullfile(data_dir, "11-Jan-2024.txt")); 


%% data validation



times_record = zeros(n_record_files, 2);


for idx_f = 1:n_record_files
    i_fname = data_fnames{idx_f};
    i_mapfile = load(i_fname);

    if idx_f > 1 && i_mapfile.(ch_name_SEG).TimeBegin - times_record(idx_f - 1, 1) > 1
        error('invalid data! data has discontinuity before %s', i_fname)
    end

    times_record(idx_f, 1) = i_mapfile.(ch_name_SEG).TimeEnd;
    times_record(idx_f, 2) = i_mapfile.(ch_name_SEG).TimeBegin;

end


%%
ch_types = {'SEG'};

for idx_f = 1:n_record_files
    i_fname = data_fnames{idx_f};
    i_mapfile = load(i_fname);


    % Initialize an empty array to store valid template indices
    validUnitIndices = [];
    
    % Loop through each field starting from 'Template1' up to 'Template8'
    for templateIdx = 1:8
        fieldName = sprintf('Template%d', templateIdx);
        
        % Check if the field is not NaN
        if ~isnan(i_mapfile.(ch_name_SEG).(fieldName))
            % If not NaN, add the index to the validTemplateIndices array
            validUnitIndices = [validUnitIndices, templateIdx];
        end
    end
    
    % Display the valid template indices
    disp('Valid Templates:');
    disp(validUnitIndices);


    for idx_ch_type = 1:numel(ch_types)
        i_ch_type = ch_types{idx_ch_type};
        ch_name = sprintf('C%s_%03d', i_ch_type, idx_record_ch);
        if isfield(i_mapfile, ch_name)
            [TimeStamps_t, datapoints, sample_rate] = ao_get_channel_info(i_mapfile, ch_name);
            ao_attributes.(i_ch_type).times(idx_f, :) = TimeStamps_t;
            ao_attributes.(i_ch_type).datapoints(idx_f, 1) = datapoints;
            ao_attributes.(i_ch_type).sample_rate(idx_f, 1) = sample_rate;
        end

%         if length(unique(ao_attributes.(i_ch_type).sample_rate)) == 1
%             error('wrong sampling rate');
%         end

        if strcmp(i_ch_type, 'SEG')
            ao_attributes.(i_ch_type).valid_unit_indices = validUnitIndices;
        end

    end
end


% %% merge all files 
% for idx_f = 1:n_record_files
%     i_fname = data_fnames{idx_f};
%     i_mapfile = load(i_fname);
%     fields = fieldnames(i_mapfile);
%     field = fields{idx_f};
%     
%     % Loop through each field
%     for i = 1:length(fields)
%         field = fields{i};
% 
%         % Check if field should be removed
%         if ~startsWith(field, {'SF_', 'CInPort', 'Ports', 'Channel'}) && ...
%                 ~strcmp(field, ch_name_RAW) && ...
%                 ~strcmp(field, ch_name_LFP) && ...
%                 ~strcmp(field, ch_name_SEG) && ...
%                 ~strcmp(field, ch_name_AI)
%             % Remove the field
%             i_mapfile = rmfield(i_mapfile, field);
%         end
%     end
%     
% end

%% -- keep important info from ao ======================================================
ao.t_TimeBegin = i_mapfile.(ch_name_SEG).TimeBegin;
ao.t_TimeEnd = i_mapfile.(ch_name_SEG).TimeEnd;

%% --------- should check all sampling rate and so on

i_ch_type = 'SEG';
i_attribute = ao_attributes.(i_ch_type);



if length(unique(i_attribute.sample_rate)) == 1
    i_att_SampleRate = i_attribute.sample_rate(1) * 1000;
end
ch_name = sprintf('C%s_%03d', i_ch_type, idx_record_ch);


% aiSpikeToRawUnitAssociation

i_mapfile = all_files(idx_f).data;
i_f_num = i_attribute.datapoints(idx_f);


i_timeBegin_TS = ao.t_TimeBegin * i_att_SampleRate


ao.(i_ch_type)(1).waveforms = i_mapfile.(ch_name).('LEVEL_SEG');
ao.(i_ch_type)(1).waveforms_timestamps = i_mapfile.(ch_name).('LEVEL') + i_mapfile.(ch_name).TimeBegin * 44000;
ao.(i_ch_type)(1).unit_index = 0;
ao.(i_ch_type)(1).channel_index = idx_record_ch;
ao.(i_ch_type)(1).interval = [double(i_mapfile.(ch_name).('LEVEL')(1) / 44000),...
    double(i_mapfile.(ch_name).('LEVEL')(end) / 44000)];



for idx_u = 1:length(ao_attributes.SEG.valid_unit_indices)
    i_unit = ao_attributes.SEG.valid_unit_indices(idx_u);
    i_waveform = i_mapfile.(ch_name).(sprintf('Template%d_SEG', i_unit));
    i_waveform_Tp = i_mapfile.(ch_name).(sprintf('Template%d', i_unit)) + i_mapfile.(ch_name).TimeBegin * 44000;

    ao.(i_ch_type)(idx_u+1).waveforms = i_waveform;
    ao.(i_ch_type)(idx_u+1).waveforms_timestamps = i_waveform_Tp;
    ao.(i_ch_type)(idx_u+1).unit_index = i_unit;
    ao.(i_ch_type)(idx_u+1).channel_index = idx_record_ch;
    ao.(i_ch_type)(idx_u+1).interval = [double(i_waveform_Tp(1)) / 44000,...
    double(i_waveform_Tp(end)) / 44000];
end



%     ao.(i_ch_type).timepoints_t = (1:length(ao.(i_ch_type).data_origin)) / ao.(i_ch_type).att_SampleRate;
% ao.(i_ch_type).indices_44k = (1:length(ao.(i_ch_type).data_origin)) * 2;

%% trigger info

i_mapfile = all_files(idx_f).data;
i_f_num = i_attribute.datapoints(idx_f);
ao.Trigger.att_SampleRate = i_mapfile.CInPort_001.KHz * 1000;
ao.Trigger.indices_44k_origin = i_mapfile.CInPort_001.Samples(1, :)' ;
ao.Trigger.events = i_mapfile.CInPort_001.Samples(2, :)' ;


ao.active_unit_info = load_interval(ao, interval_tbl, strSessionName, strRawFolder); 





out_fname = fullfile(data_dir, sprintf('ao_extracted_F240111.mat'));


ao.strctChannelInfo.m_strRawFile = out_fname;
ao.strctChannelInfo.m_strChannelName = ch_name_SEG;
ao.strctChannelInfo.m_iChannelID = idx_record_ch;
ao.strctChannelInfo.m_fGain = i_mapfile.(ch_name_SEG).Gain;
ao.strctChannelInfo.m_fThreshold = NaN;
ao.strctChannelInfo.m_bFiltersActive = NaN;
ao.strctChannelInfo.m_bSorted = 0;

save(out_fname, 'ao');

