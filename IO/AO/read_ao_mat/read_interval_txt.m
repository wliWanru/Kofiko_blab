function table = read_interval_txt(filename)
    % Open the file
    fileID = fopen(filename, 'r');
    
    % Check if file opening was successful
    if fileID == -1
        error('File could not be opened. Check the filename or path.');
    end

    % Initialize an empty cell array to store lines of text
    lines = {};

    % Read the file line by line
    tline = fgetl(fileID);
    while ischar(tline)
        lines{end+1} = tline;
        tline = fgetl(fileID);
    end

    % Close the file
    fclose(fileID);

    % Initialize an empty matrix for the table
    table = zeros(length(lines), 4);

    % Process each line
    for i = 1:length(lines)
        line = lines{i};

        % Check if the line starts with Enable or Disable
        if startsWith(line, 'Enable')
            state = 1; % Enable
        else
            state = 0; % Disable
        end

        % Extract numbers from the line
        nums = sscanf(line, '%*s %d %*s %d at %d');

        % Fill in the table
        table(i, :) = [state, nums'];
    end
end
