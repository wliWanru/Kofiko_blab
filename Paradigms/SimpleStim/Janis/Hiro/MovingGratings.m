function [param,abortflag] = MovingGratings(param,window)
% [param,abortflag] = MovingGratings(param,window)
%   presents moving gratings for "param.duration" sec in total, where 
%   each stimulus moves across the monitor with the speed of "cycles" 
%   (per second) and is presented for "param.stimlength" sec with 
%   inter-stimulus interval of "param.isi" sec.
%
%   The orientation, spatial frequency, and initial phase are randomly 
%   chosen from "param.angles" (in degrees), "param.pixels" (per period), 
%   and "param.phases" (in radian) using the "param.seed" for 
%   pseudo-random number generator.
%
%   If param.pixels>0, sinusoidal gratings.
%   If param.pixels<0, square gratings. 
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.angles : grating orientation in degrees (default: [0 90 180 270])
%       param.pixels : spatial frequency in pixels (default: [64 -256 1024])
%       param.phases : phase in radian (default: [0 pi/2 pi 3/2*pi])
%       param.cycles : drift speed (default: [.5 1 2] cycles in sec)
%       param.stimlength : stimulus presentation time (default: 1 sec) 
%       param.isi : inter-stimulus interval (default: 1 sec)
%       param.seed : for pseudorandom number generator (default: 10000)
%       window : window ID by psychophyscis toolbox
%
%   ----- output argument -----
%       param : structure containing stimulus parameteres
%       abortflag : boolean for manual interuption of stimulus by hitting ESCAPE key 
%
%   Hiroki Asari, Markus Meister Lab, Caltech

%% load input arguments
if isfield(param,'angles'), angles = param.angles(:)';
else                        angles = 0:90:270; % default: 4 orientations in degrees
end
if isfield(param,'pixels'), pixels = param.pixels(:)';
else                        pixels = [64 -256 1024]; % default: 4 spatial frequencies 
end
sqflag = pixels<0; pixels = abs(pixels);
if isfield(param,'phases'), phases = param.phases(:)';
else                        phases = 2*pi*(0:3)/4; % default: 4 phases
end
if isfield(param,'cycles'), cycles = param.cycles(:)';
else                        cycles = [.5 1 2]; % default: 3 speeds of grating in cycles per second:
end
if isfield(param,'stimlength'), stimlength = param.stimlength(1);
else                            stimlength = 1; % default: every stimulus presentation for 1 second
end
if isfield(param,'isi'), isi = param.isi(1);
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
if isfield(pref,'redchannel'),gray(1) = pref.redchannel.low;end % red-channel sync signals
    
%% turn screen gray and wait for 1 second (sync = low)
Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
vbl=Screen('Flip', window);
WaitSecs(onsetdelay);
vbl = vbl+onsetdelay*pref.ifi; 

%% moving gratings
for k=1:(duration-onsetdelay)/(stimlength+isi),
    %% pick parameters randomly
    ori = angles(randi(length(angles)));
    spa = randi(length(pixels));
    sq = sqflag(spa); spa = pixels(spa);
    cyc = cycles(randi(length(cycles)));
    phs = phases(randi(length(phases)));
        
    %% make grating
    visiblesize = ceil((pref.width+pref.height)/spa)*spa;
    x = meshgrid(-visiblesize:visiblesize, 1, 1:3);
    visiblesize = 2*visiblesize+1;
    grating = x;
    for i=1:3, 
        grating(:,:,i) = cos(2*pi*x(:,:,i)/spa+phs);
        if sq, grating(:,:,i) = sign(grating(:,:,i));end
        grating(:,:,i) = gray(i)*(1+grating(:,:,i));
    end
    if isfield(pref,'gamma'), % gamma correction
        grating = round(grating);
        for kk=fliplr(1:size(pref.gamma,1)),
            grating(grating==pref.gamma(kk,1))=pref.gamma(kk,2);
        end
    end 
    if isfield(pref,'redchannel'), grating(:,:,1) = pref.redchannel.high;end
    gratingtex = Screen('MakeTexture', window, grating, [], 1);
        
    shiftperframe= cyc * spa * pref.ifi;
        
    %% animation (sync = high)
    xoffset = 0;
    for j=1:stimlength*pref.fps
        xoffset = xoffset + shiftperframe;
        Screen('DrawTexture', window, gratingtex, [xoffset 0 xoffset + visiblesize visiblesize], [], ori);
        if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);end
        vbl = Screen('Flip', window, vbl + pref.ifi/2);
    end
    Screen('Close',gratingtex);
        
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
    
    %% gray: interval (sync = low)
    Screen(window, 'FillRect', gray, [0 0 pref.width pref.height]);
    if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
    vbl = Screen('Flip', window, vbl + pref.ifi/2);
    WaitSecs(isi);
    vbl = vbl+isi*pref.ifi; 
    
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end

%% stimulus parameters
param.angles = angles;
param.pixels = pixels;
param.phases = phases;
param.cycles = cycles;
param.stimlength = stimlength;
param.isi = isi;
param.duration = duration;
param.onsetdelay = onsetdelay;
param.seed = seed;
param.StimulusNumber = k;        