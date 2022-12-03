function varargout = PTBgui(varargin)
% PTBGUI GUI for psychophysics toolbox stimuli
%   graphical user interface to present various stimuli using the
%   procedure RunStimulu.m, and the following stimulus sets:
%
%       Checkerboard.m : checkerboard/bars with random intensity
%       FlashedGratings.m : flash various static gratings with intervals
%       FullfieldBWFlash.m : full-field contrast-inverting stimuli
%       MonitorCalibration.m : full-field uniform stimuli of different intensities 
%       MovingBars.m : various moving bars across monitor with intervals 
%       MovingGratings.m : various moving gratings with intervals
%       RandomSpots.m : looming/shrinking spots of various sizes at various locations
%
%   See also startup.m to set up preference parameters.
%
%   -------- how to add your own stimulus module ---------
%       1. Create your own stimulus m-file with the following format:
%               [param,abortflag]=YourStimulus(param,window)
%          where "param" is a structure containing stimulus parameters,
%          "window" is a window/screen ID by psychophyscis toolbox, and
%          "abortflag" is a boolean for manual interuption of stimulus by 
%          hitting ESCAPE key.  See my other stimulus modules for reference.
%
%       2. Add 'YourStimulus' to the String of handles.popupmenu1 in 
%          PTBgui_OpeningFcn (line 65)
%       
%       3. Add case 'YourStimulus' in popupmenu1_Callback (switch statement 
%          in line 156) so that you can change the stimulus parameter panel.
%
%       4. Add case 'YourSitmulus' in pushbutton1_Callback (switch 
%          statement in line 83) to load the specified stimulus parameters.
%
%   (C) Hiroki Asari, Markus Meister Lab, Caltech

%=========== start initialization code - DO NOT EDIT ============
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PTBgui_OpeningFcn, ...
                   'gui_OutputFcn',  @PTBgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%========= End initialization code - DO NOT EDIT ===========


% --- Executes just before PTBgui is made visible.
function PTBgui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject; % Choose default command line output for PTBgui
guidata(hObject, handles); % Update handles structure
% uiwait(handles.figure1); % UIWAIT makes PTBgui wait for user response (see UIRESUME)

global pref
set(handles.text12,'String',...
    ['Display info: ',num2str(pref.width),' x ',num2str(pref.height),' pixels; ',...
    num2str(pref.fps),' Hz']); % display information: resolution and frame rate

set(handles.popupmenu1,'String',... % specify the stimulus types
    {'Checkerboard';'FlashedGratings';'FullfieldBWFlash';'MonitorCalibration';'MovingBars';'MovingGratings';'RandomSpots'});


% --- Outputs from this function are returned to the command line.
function varargout = PTBgui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output; % Get default command line output from handles structure


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global param
Param = struct; % obtain parameters from the GUI panels
Param.StimulusName = get(handles.popupmenu1,'String');
Param.StimulusName = Param.StimulusName{get(handles.popupmenu1,'Value')};
Param.StimulusName = Param.StimulusName(~isstrprop(Param.StimulusName,'wspace'));
Param.logflag = get(handles.togglebutton1,'Value');

switch Param.StimulusName % choose parameters
    case 'Checkerboard'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        Param.fps = str2num(get(handles.edit4,'String'));
        Param.dx = str2num(get(handles.edit5,'String'));
        Param.dy = str2num(get(handles.edit6,'String'));
        Param.bw = str2num(get(handles.edit7,'String'));
        Param.gauss = str2num(get(handles.edit8,'String'));
        
    case 'FlashedGratings'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        Param.stimlength = str2num(get(handles.edit4,'String'));
        Param.angles = str2num(get(handles.edit5,'String'));
        Param.pixels = str2num(get(handles.edit6,'String'));
        Param.phases = str2num(get(handles.edit7,'String'));
        Param.isi = str2num(get(handles.edit8,'String'));
        
    case 'FullfieldBWFlash'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.stimlength = str2num(get(handles.edit4,'String'));    

    case 'MonitorCalibration'     
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        
    case 'MovingBars'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        Param.angles = str2num(get(handles.edit4,'String'));
        Param.height = str2num(get(handles.edit5,'String'));
        Param.width = str2num(get(handles.edit6,'String'));
        Param.speeds = str2num(get(handles.edit7,'String'));
        Param.colors = str2num(get(handles.edit8,'String'));
        Param.offset = str2num(get(handles.edit9,'String'));
        
    case 'MovingGratings'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        Param.stimlength = str2num(get(handles.edit4,'String'));
        Param.angles = str2num(get(handles.edit5,'String'));
        Param.pixels = str2num(get(handles.edit6,'String'));
        Param.phases = str2num(get(handles.edit7,'String'));
        Param.isi = str2num(get(handles.edit8,'String'));
        Param.cycles = str2num(get(handles.edit9,'String'));
        
    case 'RandomSpots'
        Param.duration = str2num(get(handles.edit1,'String'));
        Param.onsetdelay = str2num(get(handles.edit2,'String'));
        Param.seed = str2num(get(handles.edit3,'String'));
        Param.isi = str2num(get(handles.edit4,'String'));
        Param.positions = str2num(get(handles.edit5,'String'));
        Param.radii = str2num(get(handles.edit6,'String'));
        Param.speeds = str2num(get(handles.edit7,'String'));        
        Param.colors = str2num(get(handles.edit8,'String'));
end
param = RunStimulus(Param); % presents stimulus



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
global pref
stim = get(hObject,'String');
stim = stim{get(hObject,'Value')}; % stimulus type of your choice
stim = stim(~isstrprop(stim,'wspace'));
switch stim % change the stimulus parameter panel depending on stimulus type
    case 'Checkerboard'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',600);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','on','String','Frame rate (Hz)');
        set(handles.edit4,'Visible','on','String',pref.fps);
        
        set(handles.text5,'Visible','on','String','dx (pixels)');
        set(handles.edit5,'Visible','on','String',20);
        
        set(handles.text6,'Visible','on','String','dy (pixels)');
        set(handles.edit6,'Visible','on','String',20);
        
        set(handles.text7,'Visible','on','String','black&white');
        set(handles.edit7,'Visible','on','String',1);
        
        set(handles.text8,'Visible','on','String','gaussian');
        set(handles.edit8,'Visible','on','String',-1);
        
        set(handles.text9,'Visible','off');
        set(handles.edit9,'Visible','off');
        
    case 'FlashedGratings'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',600);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','on','String','Stim Length (s)');
        set(handles.edit4,'Visible','on','String',1);
        
        set(handles.text5,'Visible','on','String','Angle (degrees)');
        set(handles.edit5,'Visible','on','String','0:45:135');
        
        set(handles.text6,'Visible','on','String','Spatial Freq (pixels)');
        set(handles.edit6,'Visible','on','String','64 256 1024');
        
        set(handles.text7,'Visible','on','String','Phase (rad)');
        set(handles.edit7,'Visible','on','String','pi*(0:3)/2');
        
        set(handles.text8,'Visible','on','String','ISI (s)');
        set(handles.edit8,'Visible','on','String',1);
        
        set(handles.text9,'Visible','off');
        set(handles.edit9,'Visible','off');
        
    case 'FullfieldBWFlash'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',100);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','off');
        set(handles.edit3,'Visible','off');
        
        set(handles.text4,'Visible','on','String','Stim Length (s)');
        set(handles.edit4,'Visible','on','String',1);
        
        set(handles.text5,'Visible','off');
        set(handles.edit5,'Visible','off');
        
        set(handles.text6,'Visible','off');
        set(handles.edit6,'Visible','off');
        
        set(handles.text7,'Visible','off');
        set(handles.edit7,'Visible','off');
        
        set(handles.text8,'Visible','off');
        set(handles.edit8,'Visible','off');
        
        set(handles.text9,'Visible','off');
        set(handles.edit9,'Visible','off');
        
    case 'MonitorCalibration'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',600);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','off');
        set(handles.edit4,'Visible','off');
        
        set(handles.text5,'Visible','off');
        set(handles.edit5,'Visible','off');
        
        set(handles.text6,'Visible','off');
        set(handles.edit6,'Visible','off');
        
        set(handles.text7,'Visible','off');
        set(handles.edit7,'Visible','off');
        
        set(handles.text8,'Visible','off');
        set(handles.edit8,'Visible','off');
        
        set(handles.text9,'Visible','off');
        set(handles.edit9,'Visible','off');
        
    case 'MovingBars'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',300);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','on','String','Angle (degrees)');
        set(handles.edit4,'Visible','on','String','0:45:315');
        
        set(handles.text5,'Visible','on','String','Bar height (pixels)');
        set(handles.edit5,'Visible','on','String','512');
        
        set(handles.text6,'Visible','on','String','Bar width (pixels)');
        set(handles.edit6,'Visible','on','String','64 256');
        
        set(handles.text7,'Visible','on','String','Motion speed (pixels/s)');
        set(handles.edit7,'Visible','on','String','256 512');
        
        set(handles.text8,'Visible','on','String','color table');
        set(handles.edit8,'Visible','on','String','[0 0 0; 255 255 255]');
        
        set(handles.text9,'Visible','on','String','offset (pixels)');
        set(handles.edit9,'Visible','on','String','0');
        
    case 'MovingGratings'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',600);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','on','String','Stim Length (s)');
        set(handles.edit4,'Visible','on','String',1);
        
        set(handles.text5,'Visible','on','String','Angle (degrees)');
        set(handles.edit5,'Visible','on','String','0:90:270');
        
        set(handles.text6,'Visible','on','String','Spatial Freq (pixels)');
        set(handles.edit6,'Visible','on','String','64 256 1024');
        
        set(handles.text7,'Visible','on','String','Phase (rad)');
        set(handles.edit7,'Visible','on','String','pi*(0:3)/2');
        
        set(handles.text8,'Visible','on','String','ISI (s)');
        set(handles.edit8,'Visible','on','String',1);
        
        set(handles.text9,'Visible','on');
        set(handles.edit9,'Visible','on','String','.5 1 2');
        
    case 'RandomSpots'
        set(handles.text1,'Visible','on','String','Duration (s)');
        set(handles.edit1,'Visible','on','String',300);
        
        set(handles.text2,'Visible','on','String','Onset Delays (s)');
        set(handles.edit2,'Visible','on','String',1);
        
        set(handles.text3,'Visible','on','String','seed');
        set(handles.edit3,'Visible','on','String',10000);
        
        set(handles.text4,'Visible','on','String','ISI (s)');
        set(handles.edit4,'Visible','on','String',1);
        
        set(handles.text5,'Visible','on','String','Positions [XY])');
        set(handles.edit5,'Visible','on','String','');
        
        set(handles.text6,'Visible','on','String','Spot radius (pixels)');
        set(handles.edit6,'Visible','on','String','0 200');
        
        set(handles.text7,'Visible','on','String','R change (pixels/s)');
        set(handles.edit7,'Visible','on','String','200 -200');
        
        set(handles.text8,'Visible','on','String','color table [RGB]');
        set(handles.edit8,'Visible','on','String','[0 0 0; 255 255 255]');
        
        set(handles.text9,'Visible','off');
        set(handles.edit9,'Visible','off');
end




% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white'); % popupmenu controls usually have a white background on Windows.
end




% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
toggle = get(hObject,'Value');
if toggle == get(hObject,'Max')
    set(hObject,'String','Save log');
elseif toggle == get(hObject,'Min')
    set(hObject,'String','Do not save log');
end