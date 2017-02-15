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
init = loadInit('sensorSelfCalibratorInit');
% Convert 'calibedJointsIdxes' to matlab indexes
init.calibedJointsIdxes = structfun(...
    @(field) field+1,init.calibedJointsIdxes,'UniformOutput',false);

% Load calibration parameters
% Load existing sensors calibration (joint encoders, inertial & FT sensors, etc)
if exist(init.calibrationMapFile,'file') == 2
    load(init.calibrationMapFile,'calibrationMap');
end

if ~exist('calibrationMap','var')
    warning('calibrationMap not found');
    calibrationMap = containers.Map('KeyType','char','ValueType','any');
end

% All below procedures are optional and checked/unchecked in the main
% interface parameters

%% 1 - Run a diagnosis

if init.runDiagnosis
    % Acquire sensors measurements data while moving randomly the joints at
    % different accelerations and speeds. data batch tag = 'Random'.
    
    % Acquire training sensors data over a grid (will eventually be used for
    % calibrating the accelerometers. data batch tag = 'AccCalibrator'.
end

%% 2 - Calibrate the accelerometers gains/offsets
if init.calibrateAccelerometers
end

%% 3 - Calibrate the IMU accelerometers
if init.calibrateIMU
end

%% 4 - Calibrate the encoders joint offsets
if init.calibrateJointEncoders
    % Acquire accelerometers measurements while moving the joints following
    % a profile tagged 'jointsCalibrator'
    acqSensorDataAccessor = SensorDataAcquisition.acquireSensorData(...
        'jointEncodersCalibrator',init.robotName,init.dataPath,init.calibedParts);
    
    % Get data folder path list for joints calibration on required parts.
    % If the prior sensor data acquisition was done in N motion sequences
    % (it is the case for calibrating the torso which needs a dedicated
    % sequence), we get a folder path per sequence, so N paths.
    [dataFolderPathList,calibedPartsList] = ...
        acqSensorDataAccessor.getFolderPaths4calibedSensor('joint');
    
    % For each sequence, get the logged sensors list and respective
    % supporting parts
    [measedSensorLists,measedPartsLists] = acqSensorDataAccessor.getMeasedSensorsParts();
    
    %% calibrate joint encoders. If the torso has to be calibrated, it
    % should be before the arms since their orientation depends on the
    % torso. In the below loop processing, 'calibrationMap' (input/output)
    % is updated at each call to 'calibrateSensors'.
    cellfun(@(folderPath,calibedParts,measedSensorList,measedPartsList) ...
        JointEncodersCalibrator.calibrateSensors(...
        init.modelPath,calibrationMap,...
        calibedParts,init.calibedJointsIdxes,folderPath,...
        measedSensorList,measedPartsList),...
        dataFolderPathList,calibedPartsList,measedSensorLists,measedPartsLists);
end

%% 5 - Calibrate the FT sensors gains/offsets
if init.calibrateFTsensors
end

%% 5 - Calibrate the gyroscopes
if init.calibrateGyroscopes
end

%% Save calibration
if init.saveCalibration
    save('calibrationMap.mat','calibrationMap');
end

%% Uninitialize yarp
yarp.Network.fini();

