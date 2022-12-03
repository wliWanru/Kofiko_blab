function [param,abortflag]=FullfieldBWFlash(param,window)
% [param,abortflag]=FullfieldBWFlash(param,window)
%   presents full-field contrast inverting stimulus, every "param.duration"
%   seconds, for "param.duration" seconds in total.
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.stimlength : flickering interval for ON and OFF period (default: 1 sec each)
%       window : window ID by psychophyscis toolbox
%
%   ----- output arguments -----
%       param : structure containing stimulus parameters
%       abortflag : boolean for manual interuption of stimulus by hitting ESCAPE key 
%
%   Hiroki Asari, Markus Meister Lab, Caltech

%% stimulus parameters
if isfield(param,'duration'), duration = param.duration(1);
else                          duration = 100; % default: 100 sec
end
if isfield(param,'stimlength'), 
    stimlength = abs(param.stimlength(:));
    if length(stimlength)>1,      stimlength = stimlength(1:2);
    elseif length(stimlength)==1, stimlength = stimlength(ones(2,1));
    else                          stimlength = [1 1];
    end
else
    stimlength = [1 1]; % default: 1 sec each for ON and OFF period
end
if isfield(param,'onsetdelay'), onsetdelay = param.onsetdelay(1);
else                            onsetdelay = 1; % default: wait 1 sec and start presenting visual stimuli
end
abortflag = false;

%% define stimulus colors
global pref
black = pref.color.black;
white = pref.color.white;
if isfield(pref,'redchannel'), % red-channel sync signals
    white(1) = pref.redchannel.high;
    black(1) = pref.redchannel.low;
end    

%% turn screen "black" and wait for "onsetdelay" seconds
Screen(window, 'FillRect', black, [0 0 pref.width pref.height]); % black
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end % photodiode sync signals
Screen('Flip', window);
WaitSecs(onsetdelay);

%% start alternating black and white stimulus
for i=1:(duration-onsetdelay)/sum(stimlength), % contrast inverting
    Screen(window, 'FillRect', white, [0 0 pref.width pref.height]); % white
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);end
    Screen('Flip', window);
    WaitSecs(stimlength(1));
    Screen('Close');  
    
    % abort when ESCAPE key is down
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
    
    Screen(window, 'FillRect', black, [0 0 pref.width pref.height]); % black
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
    Screen('Flip', window);
    WaitSecs(stimlength(2));
    Screen('Close');  
    
    % abort when ESCAPE key is down
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end
    
%% stimulus parameters
param.onsetdelay = onsetdelay;
param.stimlength = stimlength;
param.duration = duration;
param.rep = i;