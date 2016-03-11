% this script generates joint encoders and accelerometers measurements data
% by simulating a trajectory and using measurement predictions. this
% simulation is based on the specified iCub model.

%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

% model and data capture file
modelPath = '../models/iCubGenova02/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova02_#1/';

% cost function: 'costFunctionSigma' / 'costFunctionSigmaProjOnEachLink'
costFunctionSelect = 'costFunctionSigma';

% sensor data parameters
timeStart = 2;  % starting time in capture data file (in seconds)
timeStop  = 28; % ending time in capture data file (in seconds)
subSamplingSize = 1000; % number of samples after sub-sampling the raw data

% define the set of joints (of whole limb) to calibrate.
% All sensors in that limb are activated.
jointsToCalibrate.parts = {'left_leg'};

%% set init parameters from interface, create model, load parameters from the 
%  specified URDF
%
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};
run ../EncodersAutoCalib/jointsNsensorsDefinitions;


% create the calibration context implementing the cost function
myCalibContext = CalibrationContextBuilder(modelPath);

% Cost Function used to optimise the offsets
eval(['costFunction = @myCalibContext.' costFunctionSelect]);


%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)

    %% joint codes and links for current part are:
    % mtbSensorCodes_list{part}
    % mtbSensorLink_list{part};
    nrOfMTBAccs = length(mtbSensorLink_list{part});

    % We will generate data for all sensors, so "activate" all of them.
    mtbSensorAct = cell(1,length(mtbSensorCodes_list{part}));
    mtbSensorAct(:,:) = {true};

    %% Parsing configuration
    %
    % build sensor data parser ('inputFilePath',nbSamples,tInit,tEnd,plot--true/false)
    data = SensorsData(dataPath,subSamplingSize,timeStart,timeStop,false);

    % add joint measurements
    data.addEncSensToData(jointsToCalibrate.parts{part}, true);

    % Load data from the file and parse it
    data.loadData();

    % add mtb sensors
    data.addMTBsensToData(jointsToCalibrate.parts{part}, 1:nrOfMTBAccs, ...
                          mtbSensorCodes_list{part}, mtbSensorLink_list{part}, ...
                          mtbSensorAct, jointsToCalibrate.mtbInvertedFrames{part},true);

    %% init joints and sensors lists & load joint data
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data,part,jointsToCalibrate);

    % load joint positions
    vecIdx = 1:data.nSamples;
    myCalibContext.loadJointNsensorsDataSubset(data,vecIdx);
    
    %% iterate over all the samples and generate sensor estimations
    myCalibContext.simulateAccelerometersMeasurements(data,vecIdx);
    
    save ('dataSimu.mat','data');
    
end
