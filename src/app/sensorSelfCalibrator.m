% Calibrates accelerometers, joint encoders using only self sensors
% measurements. this application calibrates:
% - accelerometers offsets/gains (full matrix 3x3)
% - joint encoders offsets
% - head IMU embedded accelerometers
%

% Add main folders in Matlab path
run generatePaths.m;

%% clear all variables and close all previous figures
iDynTree.Vector3(); % WORKAROUND for being able to load yarp later.
clear
close all
clc

% Create YARP Network device, for initializing YARP classes for communication
yarp.Network.init();

% load application main interface parameters
run sensorSelfCalibratorInit;

% All below procedures are optional and checked/unchecked in the main
% interface parameters

%% 1 - Run a diagnosis

if runDiagnosis
    % Acquire sensors measurements data while moving randomly the joints at
    % different accelerations and speeds. data batch tag = 'Random'.
    
    % Acquire training sensors data over a grid (will eventually be used for
    % calibrating the accelerometers. data batch tag = 'AccCalibrator'.
end

%% 2 - Calibrate the accelerometers gains/offsets
if calibrateAccelerometers
end

%% 3 - Calibrate the IMU accelerometers
if calibrateIMU
end

%% 4 - Calibrate the encoders joint offsets
if calibrateJointEncoders
    % Acquire accelerometers measurements while moving the joints following
    % a profile tagged 'jointsCalibrator'
    acqSensorDataAccessor = acquireSensorData('jointsCalibrator',robotName,dataPath,calibedParts);
    
    % Run diagnosis on sensor data
    
    % calibrate joint encoders
    
end

%% 5 - Calibrate the FT sensors gains/offsets
if calibrateFTsensors
end

%% 5 - Calibrate the gyroscopes
if calibrateGyroscopes
end


%% Uninitialize yarp
yarp.Network.fini();

