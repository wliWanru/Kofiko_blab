function [param,abortflag] = MovingBars(param,window)
% [param,abortflag] = MovingBars(param,window)
%   presents moving bar of the "param.width" (pixels) across the screen 
%   with the "param.speeds" (per second) at "param.angles" (degrees) for 
%   "param.duration" seconds in total.
%
%   The speed and angles/orientation are chosen randomly 
%   (using the "param.seed" for pseudo-random number generator).
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.angles : grating orientation in degrees (default: [0:45:315])
%       param.width : bar width in pixels (default: [128 512])
%       param.speeds : speed of bar motion in pixels per second (default: [256 512])
%       param.colors : N-by-3 matrix color tables in RGB in each row (default: black and white)
%       param.seed : for pseudorandom number generator (default: 10000)
%       window : window ID by psychophyscis toolbox
%
%   ----- output argument -----
%       param : structure containing stimulus parameteres
%       abortflag : boolean for manual interuption of stimulus by hitting ESCAPE key 
%
%   Hiroki Asari, Markus Meister Lab, Caltech

global pref;
%% load input arguments
if isfield(param,'angles'), angles = param.angles;
else                        angles = 0:45:315; % default: 8 orientations in degrees
end
if isfield(param,'width'), width = param.width;
else                       width = [64 256]; % default: 2 widths in pixels
end
R = sqrt(pref.width^2+pref.height^2);
if isfield(param,'height'), height = param.height;
else                        height = R; % default: cover entire monitor
end
height(height>R)=R; height = unique(height);
if isfield(param,'speeds'), speeds = param.speeds(param.speeds>0);
else                        speeds = [256 512]; % default: 2 speeds (pixels per second)
end
if isfield(param,'offset'), offset = param.offset;
else                        offset = [-256 0 256]; % default: 3 offsets to test
end
if isfield(param,'duration'), duration = param.duration;
else                          duration = 300; % default: 300 sec stimulus presentation
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
black = pref.color.black;
white = pref.color.white;
gray = black+white/2;
if isfield(param,'colors'), 
    colors = param.colors;
    if size(colors,2)~=3, colors = [black; white];end
else
    colors = [black; white]; % default: 2 colors
end
if isfield(pref,'redchannel'),gray(1) = pref.redchannel.low;end
    
    
%% turn screen gray and wait for 1 second
Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
vbl=Screen('Flip', window);
WaitSecs(onsetdelay);
vbl = vbl+onsetdelay*pref.ifi;     

%% moving bars
r = ceil((R/2+max(width)/2)/min(speeds)/pref.ifi); % number of frames needed to sweep to monitor center

for k=1:(duration-onsetdelay)*pref.fps/(2*r+1)
    R = height(randi(length(height)))/2; % bar height
    wid = width(randi(length(width)))/2; % bar width
    spe = speeds(randi(length(speeds)))*pref.ifi; % motion speed (pixels per frame)
    off = offset(randi(length(offset)));
    col = colors(randi(size(colors,1)),:); % bar color
    ori = angles(randi(length(angles)))/180*pi; % bar orientation in rad
    ori = [cos(ori) -sin(ori); sin(ori) cos(ori)]; % rotation matrix
    for X=(-r:r)*spe,
        if isfield(pref,'redchannel'),
            if X==0, col(1)=pref.redchannel.high; % sync pulse is high when bar reaches monitor center
            else     col(1)=pref.redchannel.low;
            end
            Screen(window, 'FillRect', [col(1) gray(2:3)], [0 0 pref.width pref.height]); 
        end
        Screen('FillPoly', window , col, [X-wid -R+off; X-wid R+off; X+wid R+off; X+wid -R+off]*ori'+repmat([pref.width pref.height]/2,4,1), 1);
        if isfield(pref,'photodiode'), 
            if X==0, Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);
            else     Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);
            end
        end
        vbl = Screen('Flip', window, vbl+pref.ifi/2);
        Screen('Close');
    end
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end
    
%% stimulus parameters
param.angles = angles;
param.width = width;
param.height = height;
param.speeds = speeds;
param.colors = colors;
param.duration = duration;
param.seed = seed;
param.onsetdelay = onsetdelay;
param.StimulusNumber = k;