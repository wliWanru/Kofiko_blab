%%%%%%%%% STIMULUS SCRIPT EXAMPLES (GUI VER.1) %%%%%%%%%%%%%
%
%   This directory contains some sample scripts for presenting visual
%   stimuli using psychophysics toolbox in Matlab at Markus Meister lab 
%   at Caltech.
%
%   The scripts should work with Matlab2012b or later with Pyschophysics 
%   toolbox ver. 3 or later.      
%
%   RunStimulus.m is the main script to present stimulus, specified by a
%   module, such as Checkerboard.m. The global variable PREF determines 
%   the preferences to choose monitor to be used, the methods for keeping 
%   track of the timing information (i.e., sync pulses by red channel vs. 
%   photodiode), gamma correction methods, color tables, and so on.  
%   Make sure to modify the startup.m first to set up PREF appropriately 
%   for your rig.
%
%   A log file is saved under the directory you specificed in PREF 
%   when param.logflag=TRUE, or toggle the "save log" button down in GUI.
%   The log file contains a structure PARAM that includes all the
%   information necessary to replicate the stimulus, including the seed for
%   random number generator. See each module script to identify how the
%   stimulus is generated.  This should be straightforward.
%
%   Please feel free to contact me if you have any question.
%
%   (C) Hiroki Asari, hasari@caltech.edu
%
%
%   ------ files ------
%       Contents.m : this file
%           |- startup.m : sets up the global variable PREF and starts GUI
%           |- PTBgui.fig : GUI panel
%           |- PTBgui.m : GUI scripts
%           |- RunStimulus.m : main script to present visual stimuli of your choice
%                   |- Checkerboard.m : checkerboard/bars with random intensity
%                   |- FlashedGratings.m : flash various static gratings with intervals
%                   |- FullfieldBWFlash.m : full-field contrast-inverting stimuli
%                   |- MonitorCalibration.m : full-field uniform stimuli of different intensities 
%                   |- MovingBars.m : various moving bars across monitor with intervals 
%                   |- MovingGratings.m : various moving gratings with intervals
%                   |- RandomSpots.m : looming/shrinking spots of various sizes at various locations
%
%
%   ------ usage example ------
%   >> startup; % initialize preferences, set paths, and open GUI
%
%   >> param.StimulusName = 'FullfieldBWFlash'; % specifying stimulus type by command
%   >> param.logflag = true; % creating LOG-file
%   >> param = RunStimulus(param); % present stimulus
%