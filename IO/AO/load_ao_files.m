% cd('IO/AO')
%addpath('read_ao_mat');


% data_dir = 'K:\data\project_data\ephys\240111';

%% record info
function full_name = load_ao_files(strRawFolder,strSessionName,data_name_format,StatisticSeverTxtfile,strcutConvertorNot)

if nargin < 1
    strRawFolder = uigetdir();
end

if isempty(StatisticSeverTxtfile)
    dateStr = datestr(datenum(strSessionName(1:6), 'yymmdd'), 'dd-mmm-yyyy');
    StatisticSeverTxtfile = sprintf("%s.txt", dateStr);
end

out_fname = [strSessionName '_AO.mat'];
full_name = fullfile(strRawFolder,out_fname);
if exist(full_name, 'file')
    fprintf('\nAO extracted file %s already exists! \n', full_name);
    user_response = input('Do you want to overwrite it? (y/n):  default n', 's');
    if isempty(user_response)
        user_response = 'n'; % Default answer
    end

    if strcmpi(user_response, 'y')
        % Continue with the program
    else
        ao_file_info = dir(full_name);
        fprintf('using existing AO file\ncreation time: %s\n', datestr(ao_file_info.datenum));
        return; % Return if user chooses not to continue
    end
end

%strSessionName = '240201_124300_MaoDan';

%data_name_format = 'mapfile*.mat';
data_fnames = get_sorted_fnames(strRawFolder, data_name_format);
n_record_files = length(data_fnames);

if length(n_record_files) < 1
    [filename pathname] = uigetfile('*.mat','Pick Plexon files(mat format)','MultiSelect','on');
    for i = 1:length(filename);
        n_record_files{i} = fullfile(pathname, filename{i});
    end
    n_record_files = sort(n_record_files);
end

if strcutConvertorNot
    data = load(data_fnames{1});
else
    data = structAOmat(data_fnames{1});
end

fdname = fieldnames(data);


%%so far let us only worry about one channel
k = 1;
for i = 1:length(fdname)
    if strcmpi(fdname{i}(1:4),'clfp');
        idx_record_ch(k) = str2num(fdname{i}(6:end));
    end
    k = k + 1;
end

idx_record_ch = idx_record_ch(1);




ch_name_SEG = sprintf('CSEG_%03d', idx_record_ch);
ch_name_LFP = sprintf('CLFP_%03d', idx_record_ch);



% Read and store all files in a structure
all_files = struct();
for idx = 1:n_record_files
    if ~strcutConvertorNot;
        newdata = structAOmat(data_fnames{idx});
    else
        newdata = load(data_fnames{idx});
    end
    all_files(idx).data = newdata;
end




%%
interval_tbl = read_interval_txt(fullfile(strRawFolder, StatisticSeverTxtfile));


%% data validation

if n_record_files > 1
    times_record = zeros(n_record_files, 2);

    for idx_f = 1:n_record_files
        i_fname = data_fnames{idx_f};
        i_mapfile = all_files(idx_f).data;

        if idx_f > 1 && i_mapfile.(ch_name_SEG).TimeBegin - times_record(idx_f - 1, 2) > 1
            error('invalid data! data has discontinuity before %s', i_fname)
        end

        times_record(idx_f, 1) = i_mapfile.(ch_name_SEG).TimeBegin;
        times_record(idx_f, 2) = i_mapfile.(ch_name_SEG).TimeEnd;
    end
end

%%


for idx_f = 1:n_record_files
    i_fname = data_fnames{idx_f};
    i_mapfile = all_files(idx_f).data;

    % Initialize an empty array to store valid template indices
    validUnitIndices = [];

    % Loop through each field starting from 'Template1' up to 'Template8'
    for templateIdx = 1:8
        fieldName = sprintf('Template%d', templateIdx);
        if ~isfield(i_mapfile.(ch_name_SEG),fieldName)
            i_mapfile.(ch_name_SEG).(fieldName) = nan;
        end
        % Check if the field is not NaN
        if ~isnan(i_mapfile.(ch_name_SEG).(fieldName))
            % If not NaN, add the index to the validTemplateIndices array
            validUnitIndices = [validUnitIndices, templateIdx];
        end
    end

    % Display the valid template indices
    disp('Valid Templates:');
    disp(validUnitIndices);


    if isfield(i_mapfile, ch_name_SEG)
        [TimeStamps_t, datapoints, sample_rate] = ao_get_channel_info(i_mapfile, ch_name_SEG);
        ao_attributes.SEG(idx_f).times = TimeStamps_t;
        ao_attributes.SEG(idx_f).datapoints = datapoints;
        ao_attributes.SEG(idx_f).sample_rate = sample_rate;
    end

    ao_attributes.SEG(idx_f).valid_unit_indices = validUnitIndices;

end


%% -- keep important info from ao ======================================================
if n_record_files == 1
    ao.t_TimeBegin = i_mapfile.(ch_name_SEG).TimeBegin;
    ao.t_TimeEnd = i_mapfile.(ch_name_SEG).TimeEnd;
else
    ao.t_TimeBegin = min(min(times_record));
    ao.t_TimeEnd = max(max(times_record));
end

%% --------- should check all sampling rate and so on

i_attribute = ao_attributes.SEG;



if length(unique([i_attribute.sample_rate])) == 1
    i_att_SampleRate = i_attribute(1).sample_rate * 1000;
end


% i_timeBegin_TS = ao.t_TimeBegin * i_att_SampleRate

validUnitIndices = cat(2,ao_attributes.SEG.valid_unit_indices);
validUnitIndices = unique(validUnitIndices);


%%
% Initialize SEG fields with empty arrays
for idx_u = 0:length(validUnitIndices)  % Assuming 8 templates plus one for 'LEVEL_SEG'
    ao.SEG(idx_u+1).waveforms = [];
    ao.SEG(idx_u+1).waveforms_timestamps = [];
    ao.SEG(idx_u+1).unit_index = idx_u;
    ao.SEG(idx_u+1).channel_index = idx_record_ch;
    ao.SEG(idx_u+1).interval = [];
end

for idx_f = 1:n_record_files
    i_mapfile = all_files(idx_f).data;
    i_attribute = ao_attributes.SEG(idx_f);
    i_att_SampleRate = i_attribute.sample_rate * 1000;

    % Adjust TimeBegin for each file
    i_timeBegin_TS = i_mapfile.(ch_name_SEG).TimeBegin * i_att_SampleRate;

    % Append LEVEL_SEG data: unit 0``
    ao.SEG(1).waveforms = [ao.SEG(1).waveforms, i_mapfile.(ch_name_SEG).('LEVEL_SEG')];
    ao.SEG(1).waveforms_timestamps = [ao.SEG(1).waveforms_timestamps, double(i_mapfile.(ch_name_SEG).('LEVEL')) + i_timeBegin_TS];

    % Append waveforms for valid units
    for idx_u = 1:length(i_attribute.valid_unit_indices)
        unit_index = i_attribute.valid_unit_indices(idx_u) + 1;  % +1 to account for 1-based indexing in MATLAB

        i_waveform = i_mapfile.(ch_name_SEG).(sprintf('Template%d_SEG', unit_index - 1));
        i_waveform_Tp = double(i_mapfile.(ch_name_SEG).(sprintf('Template%d', unit_index - 1))) + i_timeBegin_TS;

        ao.SEG(unit_index).waveforms = [ao.SEG(unit_index).waveforms, i_waveform];
        ao.SEG(unit_index).waveforms_timestamps = [ao.SEG(unit_index).waveforms_timestamps, i_waveform_Tp];

    end
end

for i = 1:length(ao.SEG)
    tmp = double(ao.SEG(i).waveforms)'/1000;
    tmp(tmp<-0.14) = -0.14; tmp(tmp>0.14) = 0.14;
    ao.SEG(i).waveforms = tmp(:,1:3:96);
end


first_timeBegin_TS = all_files(1).data.(ch_name_SEG).TimeBegin * i_att_SampleRate;
for idx = 1:length(i_attribute.valid_unit_indices) + 1
    ao.SEG(idx).interval = [(ao.SEG(idx).waveforms_timestamps(1) - first_timeBegin_TS) / i_att_SampleRate,...
        (ao.SEG(idx).waveforms_timestamps(end) - first_timeBegin_TS) / i_att_SampleRate];
end

%% LFP

allLFP = [];

% Iterate through each file
for idx_f = 1:n_record_files
    i_mapfile = all_files(idx_f).data;

    % Concatenate trigger indices and events
    allLFP = [allLFP; i_mapfile.(ch_name_LFP).Samples'];
    st(idx_f) = i_mapfile.(ch_name_LFP).TimeBegin;
    et(idx_f) = i_mapfile.(ch_name_LFP).TimeEnd;
end

% Assign the concatenated data to the ao structure
ao.LFP.att_SampleRate = all_files(1).data.(ch_name_LFP).KHz*1000;  % Assuming sample rate is the same for all files
ao.LFP.Data = allLFP;
ao.LFP.TimeBegin = min(st);
ao.LFP.TimeEnd = max(et);



%% Trigger info and concatenation for multiple files
% Initialize trigger related arrays outside the loop
all_triggers_indices = [];
all_triggers_events = [];

% Iterate through each file
for idx_f = 1:n_record_files
    i_mapfile = all_files(idx_f).data;

    % Concatenate trigger indices and events
    all_triggers_indices = [all_triggers_indices; i_mapfile.CInPort_001.Samples(1, :)'];
    all_triggers_events = [all_triggers_events; i_mapfile.CInPort_001.Samples(2, :)'];
end

% Assign the concatenated data to the ao structure
ao.Trigger.att_SampleRate = all_files(1).data.CInPort_001.KHz * 1000;  % Assuming sample rate is the same for all files
ao.Trigger.indices_44k_origin = all_triggers_indices;
ao.Trigger.events = all_triggers_events;

%% Active unit info and final save

ao.active_unit_info = load_interval(ao, interval_tbl, strSessionName, strRawFolder);

% Final save
out_fname = fullfile(strRawFolder, sprintf('%s.mat', strSessionName));
ao.strctChannelInfo.m_strRawFile = out_fname;
ao.strctChannelInfo.m_strChannelName = ch_name_SEG;
ao.strctChannelInfo.m_iChannelID = idx_record_ch;
ao.strctChannelInfo.m_fGain = all_files(1).data.(ch_name_SEG).Gain;  % Assuming gain is the same for all files
ao.strctChannelInfo.m_fThreshold = NaN;
ao.strctChannelInfo.m_bFiltersActive = NaN;
ao.strctChannelInfo.m_bSorted = 0;


save(full_name, 'ao');
disp('Alpha_Omega Data were extracted');

