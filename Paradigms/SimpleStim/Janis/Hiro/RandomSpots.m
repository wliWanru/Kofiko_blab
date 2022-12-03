function [param,abortflag] = RandomSpots(param,window)
% [param,abortflag] = RandomSpots(param,window)
%   presents spots at random "param.positions" with random "param.colors" 
%   for "param.duration" in sec with inter-stimulus interval of "param.isi".  
%   The spots can be fixed "param.radii" or looming / shrinking at 
%   "param.speeds" in pixels per seconds. 
%   The random numbers are generated using the "param.seed".
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.positions : N-by-2 matrix, each row specifying the positions of spot stimuli (default: random).
%       param.radii : radius of initial/end spot size in pixels (default: [0 200])
%       param.speeds : radial speed of spot looming/shrinking in pixels per second (default: [100 -100]).
%       param.colors : N-by-3 matrix color tables in RGB in each row (default: black and white).
%       param.isi : inter-stimulus interval in seconds (default: 1).
%       param.seed : for pseudorandom number generator (default: 10000).
%
%   ----- output argument -----
%       param : structure containing parameteres needed to reproduce 
%           the presented stimuli.  Saved in the log file if logflag=TRUE.
%
%   Hiroki Asari, Markus Meister Lab, Caltech

%% load input arguments
if isfield(param,'positions'), 
    positions = param.positions;
    if size(positions,2)~=2, positions=[];end
else
    positions = []; % default: random
end
if isfield(param,'radii'), radii = abs(param.radii(:))';
else                       radii = [0 200]; % default: 2 initial spot radius in pixels
end
if isfield(param,'speeds'), speeds = param.speeds(:)';
else                        speeds = [200 -200]; % default: 2 speeds in pixels per sec (positive, looming; negative, shrinking)
end
if isfield(param,'duration'), duration = param.duration(1);
else                          duration = 300; % defaut: 300 sec
end
if isfield(param,'onsetdelay'), onsetdelay = param.onsetdelay(1);
else                            onsetdelay = 1; % default: 1 sec
end
if isfield(param,'isi'), isi = abs(param.isi(1));
else                     isi = 1; % default inter-stimulus interval: 1 sec
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
gray = black+white/2;
if isfield(param,'colors'), 
    colors = param.colors;
    if size(colors,2)~=3, colors = [black; white];end
else
    colors = [black; white]; % default: 2 colors
end
if isfield(pref,'redchannel'),gray(1) = pref.redchannel.low;end
    
%% turn screen gray and wait for 1 second
c0 = clock;
Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
vbl=Screen('Flip', window);
WaitSecs(onsetdelay);
vbl = vbl+onsetdelay*pref.ifi;    

%% random spot stimulus
R = sqrt(pref.width^2+pref.height^2); % maximum spot radius size to cover the monitor
radii(radii>R)=R; radii=unique(radii);
if all(speeds==0), r = ceil(isi/pref.ifi); % in case of no motion, show spot stimulus for ISI sec
else               r = ceil((R-min(radii))/min(abs(speeds(speeds~=0)))/pref.ifi);
end
for k=1:(duration-onsetdelay)*pref.fps/(r+1+isi/pref.ifi)
    if isempty(positions), pos = [randi(pref.width) randi(pref.height)];
    else                   pos = positions(randi(size(positions,1)),:);
    end
    col = colors(randi(size(colors,1)),:);
    if isfield(pref,'redchannel'), 
        col(1) = pref.redchannel.high;
        Screen(window, 'FillRect', [pref.redchannel.high gray(2:3)], [0 0 pref.width pref.height]); 
    end
    ini = radii(randi(length(radii)));
    spe = speeds(randi(length(speeds)))*pref.ifi;
    if spe>=0, spe = (0:r)*spe; % looming spot
    else       spe = fliplr(0:r)*abs(spe); % shrinking spot
    end
    for X=spe,
        Screen('FillOval', window, col, [pos-ini-X pos+ini+X]);
        if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);end
        vbl = Screen('Flip', window, vbl+pref.ifi/2);
    end    
    Screen('Close');
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
    
    %% gray
    Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
    vbl=Screen('Flip', window, vbl+pref.ifi/2);
    WaitSecs(isi);
    vbl = vbl+isi*pref.ifi;    
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end

%% stimulus parameters
param.positions = positions;
param.radii = radii;
param.speeds = speeds;
param.colors = colors;
param.duration = duration;
param.onsetdelay = onsetdelay;
param.seed = seed;
param.StimulusNumber = k;