%%
% Init parameters of the joint offsets calibration for fine tuning of the
% application. Advanced users only.
%%

% 'simu' or 'target' mode
loadSource = 'dumpFile';
saveToCache = false;
offsetsGridResolution = 10*pi/180; % step between 2 offsets for each joint DOF (degrees)
offsetsGridRange = 5*pi/180; % min/max (degrees)
offsetedQsIdxs = 1:6;

loadRandomDataIdxes = false;
saveRandomDataIdxes = false;
randomDataIdxesFile = './data/randomIdx.mat';

% Optimisation configuration
startPoint2Boundary = 20*pi/180; % 20 deg
% cost function: 'costFunctionSigma' / 'costFunctionSigmaProjOnEachLink'
costFunctionSelect = 'costFunctionSigma';
shuffle = false;

% The main single data bucket of (timeStop-timeStart)/10ms samples is sub-sampled to
% 'subSamplingSize' samples. A subset of 'subSamplingSize*subsetVec_size_frac' is
% then selected for running the optimisation on.
% The subset can be selected randomly.
% The subset size = 1/number_of_subset_init of the total data set size
number_of_subset_init = 1;
subsetVec_size_frac = 1/number_of_subset_init;

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use the end time from log
subSamplingSize = 1000; % number of samples after sub-sampling the raw data

%% Define parameters for all joints (calibrated or not)
%

% Optimization starting point
calibedJointsDq0.left_arm = [0 0 0 0];
calibedJointsDq0.right_arm = [0 0 0 0];
calibedJointsDq0.left_leg = [0 0 0 0 0 0];
calibedJointsDq0.right_leg = [0 0 0 0 0 0];
calibedJointsDq0.torso = [0 0 0];
calibedJointsDq0.head = [0 0 0];
