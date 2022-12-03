%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This script sets up the global variable PREF.
%   Run this script upon starting up the matlab psychophysics toolbox
%
%   It also shows GUI for convenience.
%
%   (C) Hiroki Asari, Markus Meister Lab, Caltech


global pref param
warning('OFF');

%% psychophisics toolbox parameters
% pick appropriate screen if you have multiple displays
KbName('UnifyKeyNames');
pref.screenid = 0;max(Screen('Screens'));  
[pref.width, pref.height]=Screen('WindowSize', pref.screenid);
pref.fps = Screen('FrameRate', pref.screenid); % frames per seconds



%% default user name
pref.username = 'Hiro';


%% default path
dirname = 'C:\Users\hiro\Documents\MeisterLab\';
if exist(dirname,'dir')==7, pref.home = dirname;
else                        pref.home = pwd;
end
% pref.data = [pref.home,'data',filesep]; % original data directory
% pref.processed = [pref.home,'processed',filesep]; % processed data directory
pref.stimuli = [pref.home,'phychtoolstimgui',filesep]; % stimulus files
pref.log = [pref.home,'StimLogs',filesep]; % stimulus log directory

%%%%% if needed %%%%%
% cd(pref.home);
cd(pref.stimuli);

% addpath(pref.home);
% addpath(pref.data);
% addpath(pref.processed);
% addpath(pref.stimuli);
% addpath([pref.home,'scripts']);

clear dirname


%% time stamp methods
%   With the field PHOTODIODE, we will present a square on the bottom right
%   corner, for example, to send sync signals to photodiode. 
%   With the field REDCHANNEL, we will use the red-channel for the sync
%   signals.
%
if true, % use photodiode on CRT
    dx = 0.05;
    dx = ceil(sqrt(pref.width.^2+pref.height.^2)*dx);
    pref.photodiode.size = [0 pref.height-dx dx pref.height];
    pref.photodiode.high = [196 196 196]; % [R G B] for high intensity signal
    pref.photodiode.low = [96 96 96]; % [R G B] for low intensity signal
    clear dx
end

if false, % use red-channel
    pref.redchannel.high = 255;
    pref.redchannel.low = 64;
end


%% gamma correction table %%%%%
%   With the field GAMMA, we will perform gamma correction on the stimulus
%   intensity using the ad hoc look-up table methods in each M-file.
%
%   The GAMMA field should be an N-by-2 matrix containing the followings:
%       1st column: command intensity, such as (0:255)'
%       2nd column: converted intensity
%
%   The look-up table can be simply made as follows.
%       >> x = (0:255)'; % command intensity
%       >> y =  x.^2; % measured intensity by using MonitorCalibration.m for example
%       >>
%       >> y = y-min(y);
%       >> z = zeros(size(x));
%       >> dy = max(y)/length(x);
%       >> for i=1:length(x),z(i) = sum(y<=dy*(i-1));end;
%       >>
%       >> gamma = [x z];

filename = [pref.home,'gamma',filesep,'gamma.mat'];
if exist(filename,'file')==2,
    load(filename,'gamma');
    if exist('gamma','var')==1,
        if isstruct(gamma) && isfield(gamma,'intensity'),
            pref.gamma = gamma.intensity(:,[1 3]); % from GetGammaCurve.m
        elseif isnumeric(gamma) && ~isempty(gamma),
            pref.gamma = gamma;
        end
    end
    
    if true, % use the psychophysics toolbox build-in methods
%       gamma = Screen('ReadNormalizedGammaTable', pref.screenid);
        gamma = pref.gamma(:,2);
        pref = rmfield(pref,'gamma');
        gamma = gamma-min(gamma);
        gamma = repmat(gamma/max(gamma),1,3);
        Screen('LoadNormalizedGammaTable', pref.screenid, gamma);
    end
end
clear filename gamma ans


%% color table %%%%%
%   Define your own color table.

pref.color.white = repmat(WhiteIndex(pref.screenid),1,3);
pref.color.black = repmat(BlackIndex(pref.screenid),1,3);
% pref.color.white = [255 255 255];
% pref.color.black = [0 0 0];



%% start GUI
if true, 
    run PTBgui;
end
% Call Psychtoolbox-3 specific startup function:
if exist('PsychStartup'), PsychStartup; end;

