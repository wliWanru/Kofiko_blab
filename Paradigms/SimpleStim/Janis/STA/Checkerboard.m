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



%% load input arguments
[window, rect] = Screen('OpenWindow',0);

width=200; % default: present checker board on 200 pixels width
height=200;% default: present checker board on 200 pixels height
dx = 20; % default: checker width of 20 pixels
dy = 20; % default: checker height of 20 pixels
duration = 600; % default: 600 seconds
fps=16;
bw = 1; % default: black-and-white patterns
gauss = -1; % default: binary
seed = 10000; % default seed for pseudorandom number generator
rng(seed, 'twister');  % set the seed


%% define stimulus colors
black = [0 0 0];
white = [255 255 255];
gray = (black+white)/2;


%% start presenting checkerboard patterns        
for i=0:duration*fps,
    noiseimg = randn(ceil(width/dx)*ceil(height/dy),3);
    if gauss>0, % gaussian
        noiseimg = gauss*noiseimg+repmat(gray,size(noiseimg,1),1);
%         %Gamma correction
%             noiseimg = round(noiseimg);
%             for k=fliplr(1:size(pref.gamma,1)),
%                 noiseimg(noiseimg==pref.gamma(k,1))=pref.gamma(k,2);
%             end
         
    else % binary
        for k=1:3, 
            noiseimg(noiseimg(:,k)<=0,k)=black(k);
            noiseimg(noiseimg(:,k)~=black(k),k)=white(k);
        end
    end
    noiseimg = reshape(noiseimg,ceil(height/dy),ceil(width/dx),3);
    if bw==1, for k=2:3,noiseimg(:,:,k)=noiseimg(:,:,1);end;end % black-and-white
        
        
    texture=Screen('MakeTexture', window, noiseimg);
    Screen('DrawTexture', window, texture, [], [0 0 width height], [], 0);
    Screen('Close', texture); % to save memory usage
    vbl=Screen('Flip', window, vbl+(floor(1/10/fps)-1)*10);

        
    %% abort when ESCAPE key is hit
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE')), abortflag=true;break;end
end

