function sorted_data_fnames = get_sorted_fnames(data_dir, format_string)
% This function retrieves and sorts filenames in the specified directory
% matching the given format string.

% Full path with format string
search_path = fullfile(data_dir, format_string);

% Get a list of files matching the format string
files = dir(search_path);

% Extract the names of the files
data_fnames = fullfile({files.folder}, {files.name});

% Sort the filenames
sorted_data_fnames = sort(data_fnames)' ;
end
