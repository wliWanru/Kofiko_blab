function [param,abortflag]=Checkerboard(param,window)
% [param,abortflag]=Checkerboard(param,window)
%   presents random checkerboard patterns (square size: "param.dx" by 
%   "param.dy") for "param.duration" seconds with the frame rate of 
%   "param.fps".  
%   If "param.bw" is TRUE (default), then the stimulus is black and white. 
%   If FALSE, then the stimulus is RGB color.
%   If "param.gauss" is negative, then the stimulus is binary. If positive, 
%   then gaussian with standard deviation of "param.gauss".
%   Random numbers are generated based on the "param.seed".
%
%   See also RunStimulus.m
%
%   ----- input arguments (stimulus-specific params only) -----
%       param.dx : checkerboard width (default: 20 pixels)
%       param.dy : checkerboard height (default: 20 pixels)
%       param.fps : stimulus frame rate per second (default: 60 fps)
%       param.bw : black-and-white boolean flag (default: TRUE)
%       param.gauss : standard deviation for gaussian stimulus (dafault: -1, i.e., binary)
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
if isfield(param,'dx'), dx = param.dx(1);
else                    dx = 20; % default: checker width of 20 pixels
end
if isfield(param,'dy'), dy = param.dy(1);
else                    dy = 20; % default: checker height of 20 pixels
end
if isfield(param,'duration'), duration = param.duration(1);
else                          duration = 600; % default: 600 seconds
end
if isfield(param,'fps'), fps = param.fps(1);
else                     fps = pref.fps;
end
if isfield(param,'bw'), bw = param.bw(1);
else                    bw = 1; % default: black-and-white patterns
end
if isfield(param,'gauss'), gauss = param.gauss(1);
else                       gauss = -1; % default: binary
end
if isfield(param,'onsetdelay'), onsetdelay = param.onsetdelay(1);
else                            onsetdelay = 1; % default: 1 sec
end
if isfield(param,'seed'), seed = param.seed(1);
else                      seed = 10000; % default seed for pseudorandom number generator
end
rng(seed, 'twister');  % set the seed
abortflag=false;   

%% define stimulus colors
black = pref.color.black;
white = pref.color.white;
gray = (black+white)/2;

%% turn screen black and wait for 1 second    
if isfield(pref,'redchannel'), % red-channel sync signals
    Screen(window, 'FillRect', [pref.redchannel.low black(2:3)], [0 0 pref.width pref.height]);
else
    Screen(window, 'FillRect', black, [0 0 pref.width pref.height]); % black
end
if isfield(pref,'photodiode'), Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);end
vbl=Screen('Flip', window);
WaitSecs(onsetdelay);
vbl = vbl+onsetdelay*pref.ifi;

%% start presenting checkerboard patterns        
for i=0:duration*fps,
    noiseimg = randn(ceil(pref.width/dx)*ceil(pref.height/dy),3);
    if gauss>0, % gaussian
        noiseimg = gauss*noiseimg+repmat(gray,size(noiseimg,1),1);
        if isfield(pref,'gamma'), % gamma correction
            noiseimg = round(noiseimg);
            for k=fliplr(1:size(pref.gamma,1)),
                noiseimg(noiseimg==pref.gamma(k,1))=pref.gamma(k,2);
            end
        end 
    else % binary
        for k=1:3, 
            noiseimg(noiseimg(:,k)<=0,k)=black(k);
            noiseimg(noiseimg(:,k)~=black(k),k)=white(k);
        end
    end
    noiseimg = reshape(noiseimg,ceil(pref.height/dy),ceil(pref.width/dx),3);
    if bw==1, for k=2:3,noiseimg(:,:,k)=noiseimg(:,:,1);end;end % black-and-white
        
    if isfield(pref,'redchannel'), % red-channel sync signals
        if mod(i,2)==0, noiseimg(:,:,3)=pref.redchannel.high;
        else            noiseimg(:,:,3)=pref.redchannel.low;
        end
    end
        
    texture=Screen('MakeTexture', window, noiseimg);
    Screen('DrawTexture', window, texture, [], [0 0 pref.width pref.height], [], 0);
    Screen('Close', texture); % to save memory usage
        
    %% photodiode sync signal: alternate high and low values
    if isfield(pref,'photodiode'), 
        if mod(i,2)==0, Screen(window, 'FillRect', pref.photodiode.high, pref.photodiode.size);
        else            Screen(window, 'FillRect', pref.photodiode.low, pref.photodiode.size);
        end
    end
    vbl=Screen('Flip', window, vbl+(floor(1/pref.ifi/fps)-1)*pref.ifi);
        
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end

%% stimulus parameters
param.dx = dx;
param.dy = dy;
param.duration = duration;
param.fps = fps;
param.bw = bw;
param.gauss = gauss;
param.onsetdelay = onsetdelay;
param.seed = seed;
param.rectScreen = [pref.width pref.height];