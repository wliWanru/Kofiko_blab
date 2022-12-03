function param=RunStimulus(param)
% RunStimulus(param)
%   main procedure for presenting visual stimuli specified by
%  "param.StimulusName" using pyschophysics toolbox.
%
%   You can abort stimulus presentation by hitting ESCAPE key.
%
%   ----- input argument -----
%       param : structure containing the following fields
%           .StimulusName : specifying stimulus type
%           .logflag : boolean for saving log file
%           .duration : stimulus duration
%           .onsetdelay : wait period before stimulus presentation
%         and other stimulus-specific params.
%
%   ----- output argument -----
%       param : structure containing stimulus parameters
%
%   Hiroki Asari, Markus Meister Lab, Caltech

%% load input arguments
if isfield(param,'StimulusName'),
    stim = str2func(param.StimulusName); % choose stimulus type
else
    error('Please specify the stimulus type: "param.StimulusName"');
end
if isfield(param,'logflag') && param.logflag==1, 
    logflag = true; % save log file 
else
    logflag = false; % do not save log file
end
global pref;

try
    %% initialize monitor     
%     AssertOpenGL; % if you prefer OpenGL-based version    
    Screen('Preference', 'Verbosity', 1);
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebugLevel', 1);
    
    window = Screen('OpenWindow',pref.screenid);
    pref.ifi = Screen('GetFlipInterval', window); % inter-frame intervals in sec
    
    HideCursor;
    Priority(MaxPriority(window));    
    
    %% present stimulus type of your choice    
    c0 = clock; % stimulus start
    [param,abortflag] = stim(param,window);
    
    %% end of stimulus
    c1=clock;
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    
    %% save log file 
    % Under the directory "YYYYMMDD" with the stimulus name plus suffix.
    if isfield(pref,'username'), param.Experimenter = pref.username;
    else                         param.Experimenter = [];
    end
    param.StartTime = c0;
    param.EndTime = c1;
    if logflag && ~abortflag,
        y = cell(1,3);
        for i=1:3,
            y{i}=num2str(c1(i));
            if length(y{i})<2,y{i} = ['0',y{i}];end
        end
        if isfield(pref,'log'), y = [pref.log,cell2mat(y)];
        else                    y = [pwd,cell2mat(y)];
        end
        if exist(y,'dir')==0,mkdir(y);end % make directory if not exist
        save([y,filesep,param.StimulusName,'_',num2str(length(dir(y))-2),'.mat'], 'param');
    end
    
catch %% close screen in case of any error
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    psychrethrow(psychlasterror);
end