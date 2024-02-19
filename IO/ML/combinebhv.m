function [bhvmat fn folder] = combinebhv;

folder = uigetdir('EphysData\','Pick the Raw folder');
bhvlist = dir(fullfile(folder,'*.bhv2'));

existed_ML_dirs = dir(fullfile(folder,'*_ML.mat'));
if length(existed_ML_dirs) > 1
    warning('multiple ML files exists');
    return
end

existed_ML_file_info = existed_ML_dirs(1);
existed_ML_file_dir = fullfile(existed_ML_file_info.folder, existed_ML_file_info.name); 
if exist(existed_ML_file_dir, 'file')
    fprintf('\nML extracted file %s already exists! \n', existed_ML_file_dir);
    user_response = input('Do you want to overwrite it? (y/n): default n ', 's');

    if isempty(user_response)
        user_response = 'n'; % Default answer
    end

    if strcmpi(user_response, 'y')
        % Continue with the program
    else
        bhvmat = load(existed_ML_file_dir).('bhvmat');
        want_pattern = '^(.*)_ML\.mat$'; % Regular expression pattern
        matched_str = regexp(existed_ML_file_info.name, want_pattern, 'tokens', 'once');
        fn = matched_str{1}; 
        fprintf('using existing AO file\ncreation time: %s\n', datestr(existed_ML_file_info.datenum));
        return; % Return if user chooses not to continue
    end
end

bhvmat = [];

for i = 1:length(bhvlist)
    disp(['Now Read ' bhvlist(i).name]);
    bhv = mlread(fullfile(folder,bhvlist(i).name));
    bhvmat = [bhvmat bhv];
end

for i = 1:length(bhvmat)
    trialstart(i) = datenum(bhvmat(i).TrialDateTime);
end

ff = bhvlist(1).name;
index = find(ff=='_');
subjname = ff(index(1)+1:index(2)-1);

[starttime index] = sort(trialstart)

timestring = datestr(starttime(1),'yymmdd_HHMMSS');

bhvmat = bhvmat(index)

fn = [timestring '_' subjname];

savename = [fn '_ML.mat'];

save(fullfile(folder,savename),'bhvmat');
