function [param,abortflag]=MonitorCalibration(param,window)
% [param,abortflag]=MonitorCalibration(param,window)
%   presents full-field stimulus of various intensities drawn from uniform
%   distribution, from black to white.
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.seed : for pseudorandom number generator (default: 10000).
%       window : window ID by psychophyscis toolbox
%
%   ----- output argument -----
%       param : structure containing stimulus parameteres
%       abortflag : boolean for manual interuption of stimulus by hitting ESCAPE key 
%       
%   Hiroki Asari, Markus Meister Lab, Caltech

%% stimulus parameters
if isfield(param,'duration'), duration = param.duration(1);
else                          duration = 600; % default: 600 sec
end
if isfield(param,'onsetdelay'), onsetdelay = param.onsetdelay(1);
else                            onsetdelay = 1; % default: wait 1 sec and start presenting visual stimuli
end
if isfield(param,'seed'), seed = param.seed(1);
else                      seed = 10000; % default seed for pseudorandom number generator
end
rng(seed, 'twister'); % set the seed
abortflag = false;

%% define stimulus colors
global pref
black = BlackIndex(pref.screenid); % use the monitor default color
white = WhiteIndex(pref.screenid);

%% create intensity values from random uniform distribution
intensity = rand(1,duration*pref.fps);
intensity = floor(black*(1-intensity)+(white+1)*intensity);
intensity(intensity>white)=white;
    
%% gamma correction if look-up table exists
if isfield(pref,'gamma'),
    for k=fliplr(1:size(pref.gamma,1)),
        intensity(intensity==pref.gamma(k,1))=pref.gamma(k,2);
    end
end    

%% turn screen black and wait for 1 second    
Screen(window, 'FillRect', black, [0 0 pref.width pref.height]); % black
vbl = Screen('Flip', window);
WaitSecs(onsetdelay);
vbl = vbl+onsetdelay*pref.ifi;      

%% show stimului
for k=1:length(intensity),
    Screen(window, 'FillRect', intensity(k), [0 0 pref.width pref.height]);
    vbl=Screen('Flip', window, vbl+pref.ifi*.5);
    Screen('Close');
        
    % abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end 
    
%% stimulus parameters
param.duration = duration;
param.seed = seed;
param.onsetdeay = onsetdelay;
param.intensity = intensity;    