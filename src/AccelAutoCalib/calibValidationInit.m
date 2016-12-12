% 'matFile' or 'dumpFile' mode
loadSource = 'dumpFile';
saveToCache = false;
loadJointPos = true;

% model and data capture file
modelPath = '../models/iCubGenova05/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova05_#4/';
dataSetNb = '';
calibrationMapFile = './data/calibrationMap.mat';
iterator = 1; % default value in case no iterator file exists
              % For reseting the iterator, just delete the file
              % ./data/test/iterator.mat .
logTest = true; % if set to true, current iter number (saved in a file) 
% is incremented, all data is saved and figures printed in a new folder
% indexed by the iter number.
% Above 4 parameters are saved in text format for easier search from
% a file explorer app.

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use 
                % the end time from log
% filtering/subsampling: the main single data bucket of (timeStop-timeStart)/10ms 
% samples is sub-sampled to 'subSamplingSize' samples for running the ellipsoid fitting.
subSamplingSize = 1000;

% define the limb from which we will calibrate all the sensors.
% Activate all the sensors of that limb.
parts = {'left_leg'};
