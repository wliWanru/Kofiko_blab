function [param,abortflag]=FlashedGratings(param,window)
% [param,abortflag]=FlashedGratings(param,window)
%   presents grating stimuli for "param.duration" sec in total, where 
%   each stimulus lasts for "param.stimlength" sec with inter-stimulus interval 
%   of "param.isi" sec.
%   The orientation, spatial frequency, and phase are randomly chosen from
%   "param.angles", "param.pixels", and "param.phases" using the 
%   "param.seed" for pseudo-random number generator.
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.angles : grating orientation in degrees (default: [0 45 90 135])
%       param.pixels : spatial frequency in pixels (default: [64 256 1024])
%       param.phases : phase in radian (default: [0 pi/2 pi 3/2*pi])
%       param.stimlength : stimulus presentation time (default: 1 sec)
%       param.isi : inter-stimulus intervals (default: 1 sec)
%       param.seed : for pseudorandom number generator (default: 10000)
%       window : window ID by psychophyscis toolbox
%
%   ----- output argument -----
%       param : structure containing stimulus parameteres
%       abortflag : boolean for manual interuption of stimulus by hitting ESCAPE key 
%
%   Hiroki Asari, Markus Meister Lab, Caltech

%% load input arguments
if isfield(param,'angles'), angles = param.angles;
else                        angles = 0:45:135; % default: 6 orientations
end
if isfield(param,'pixels'), pixels = param.pixels;
else                        pixels = [64 256 1024]; % default: 4 spatial frequencies
end
if isfield(param,'phases'), phases = param.phases;
else                        phases = 2*pi*(0:3)/4; % default: 4 phases
end
if isfield(param,'stimlength'), stimlength = param.stimlength(1);
else                            stimlength = 1; % default: every stimulus presentation for 1 second
end
if isfield(param,'isi'), isi = abs(param.isi(1));
else                     isi = 1; % default: inter-stimulus interval of 1 sec
end
if isfield(param,'duration'), duration = param.duration(1);
else                          duration = 600; % default: 600 sec in total
end
if isfield(param,'onsetdelay'), onsetdelay = param.onsetdelay(1);
else                            onsetdelay = 1; % default: 1 sec
end
if isfield(param,'seed'), seed = param.seed(1);
else                      seed = 10000; % default seed for pseudorandom number generator
end
rng(seed, 'twister');
abortflag = false;

%% define stimulus colors
global pref;
black = pref.color.black;
white = pref.color.white;
gray = (black+white)/2;
x = meshgrid(0:pref.width*2-1, 1, 1:3);
if isfield(pref,'redchannel'),gray(1) = pref.redchannel.low;end % red-channel sync signals

%% turn screen gray and wait for 1 second (sync = low)
Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
Screen('Flip', window);
WaitSecs(onsetdelay);
    
%% start presenting stimuli
for k=1:(duration-onsetdelay)/(stimlength+isi),
    ori = angles(randi(length(angles)));
    spa = pixels(randi(length(pixels)));
    phs = phases(randi(length(phases)));
        
    grating = x;
    for i=1:3, grating(:,:,i) = gray(i)*(1+cos(2*pi*x(:,:,i)/spa+phs));end
    if isfield(pref,'gamma'),
        grating = round(grating);
        for kk=fliplr(1:size(pref.gamma,1)), 
            grating(grating==pref.gamma(kk,1))=pref.gamma(kk,2);
        end
    end 
    if isfield(pref,'redchannel'), grating(:,:,1) = pref.redchannel.high;end
    gratingtex = Screen('MakeTexture', window, grating, [], 1);
        
    %% grating (sync = high)
    Screen('DrawTexture', window, gratingtex, [0 0 pref.width+pref.height pref.width+pref.height], [], ori);
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);end
    Screen('Flip', window);
    WaitSecs(stimlength);
    Screen('Close');      
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
    
    %% gray (sync = low)
    Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
    Screen('Flip', window);
    WaitSecs(stimlength);
    Screen('Close');  
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end

%% stimulus parameters
param.angles = angles;
param.pixels = pixels;
param.phases = phases;
param.stimlength = stimlength;
param.isi = isi;
param.duration = duration;
param.onsetdelay = onsetdelay;
param.seed = seed;
param.StimulusNumber = k;