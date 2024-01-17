function fileName = fnGetMlSessionName(directoryPath, fileExtension)
% Get a list of all files in the directory
fileList = dir(fullfile(directoryPath, ['*' fileExtension]));

% Check if any files with the specified extension were found
if isempty(fileList)
    fileName = ''; % Return an empty string if no matching files found
    error('No files with extension %s found in the directory.\n', fileExtension);
else
    % Get the name of the first file with the specified extension (without its path)
    [~, fileName, ~] = fileparts(fileList(1).name);
end
end
