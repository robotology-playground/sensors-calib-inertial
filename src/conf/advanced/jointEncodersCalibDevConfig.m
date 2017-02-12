%%
% Init parameters of the joint offsets calibration script
%%

% 'simu' or 'target' mode
runMode = 'target';
offsetsGridResolution = 10*pi/180; % step between 2 offsets for each joint DOF (degrees)
offsetsGridRange = 5*pi/180; % min/max (degrees)
offsetedQsIdxs = 1:6;

% model and data capture file
%modelPath = '../models/iCubGenova02/iCubGenova02wAllAcc.urdf';
modelPath = '../models/iCubGenova05/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova05_#5/';
%dataPath  = '../../data/calibration/dumper/icubGazeboSim/';
dataSetNb = '';
%dataSetNb = '_00018';
calibrationMapFile = '../AccelAutoCalib/data/calib/calibrationMap_#6.mat';
loadRandomDataIdxes = false;
saveRandomDataIdxes = true;
saveCalib = true;
randomDataIdxesFile = './data/randomIdx.mat';

% Optimisation configuration
[optimFunction,options] = getOptimConfig();
startPoint2Boundary = 20*pi/180; % 20 deg
% cost function: 'costFunctionSigma' / 'costFunctionSigmaProjOnEachLink'
costFunctionSelect = 'costFunctionSigma';
shuffle = true;

% The main single data bucket of (timeStop-timeStart)/10ms samples is sub-sampled to
% 'subSamplingSize' samples. A subset of 'subSamplingSize*subsetVec_size_frac' is
% then selected for running the optimisation on.
% The subset can be selected randomly.
% The subset size = 1/number_of_subset_init of the total data set size
number_of_subset_init = 5;
subsetVec_size_frac = 1/number_of_subset_init;

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use the end time from log
subSamplingSize = 1000; % number of samples after sub-sampling the raw data

% define the set of joints (of whole limb) to calibrate and activate the sensors
% in that limb.
parts = {'left_arm'}; %loop on 1 single cost f 
