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

%Clear static data
clear RobotModel Timers RemoteControlBoardRemapper SequenceParams;

% Create YARP Network device, for initializing YARP classes for communication
yarp.Network.init();

% load application main interface parameters
init = Init.load('sensorSelfCalibratorInit');

% Set parameters from environment
if isempty(init.robotName)
    init.robotName = getenv('YARP_ROBOT_NAME');
end
if isempty(init.modelPath)
    % Let Yarp resource finder get the model path for 'robotName'. Trash the
    % error/warning output and get only the result path
    [status,path] = system('yarp resource --find model.urdf 2> /dev/null');
    if status
        error('robot model not found !!');
    end
    path = strip(path); % remove spaces from the sides of the string
    init.modelPath = strip(path,'"'); % remove the quotation marks
end

% Load calibration parameters
% Load existing sensors calibration (joint encoders, inertial & FT sensors, etc)
if exist(init.calibrationMapFile,'file') == 2
    load(init.calibrationMapFile,'calibrationMap');
end

if ~exist('calibrationMap','var')
    warning('calibrationMap not found');
    calibrationMap = containers.Map('KeyType','char','ValueType','any');
end

% Load last acquired data accessors from file
if exist('lastAcqSensorDataAccessorMap.mat','file') == 2
    load('lastAcqSensorDataAccessorMap.mat','lastAcqSensorDataAccessorMap');
end
if ~exist('lastAcqSensorDataAccessorMap','var')
    lastAcqSensorDataAccessorMap = containers.Map('KeyType','char','ValueType','any');
end

% All below procedures are optional and checked/unchecked in the main
% interface parameters

isTaskScheduled = [...
    init.calibrateAccelerometers,...
    init.calibrateJointEncoders,...
    init.acquireSensorsTestData,...
    init.calibrateFTsensors,...
    init.calibrateGyroscopes];

calibratorTasks = {...
    'accelerometersCalibrator',...
    'jointEncodersCalibrator',...
    'sensorsTestDataAcquisition',...
    'ftSensorsCalibrator',...
    'gyroscopesCalibrator'};

taskInitParams = {...
    init.accelerometersCalib,...
    init.jointEncodersCalib,...
    init.sensorsTestDataAcq,...
    init.ftSensorsCalib,...
    init.gyroscopesCalib};

calibedSensors = {'acc','joint','acc','ftSensor','gyro'};

% build maps for above lists
taskInitParamsMap = containers.Map(calibratorTasks,taskInitParams);
calibedSensorsMap = containers.Map(calibratorTasks,calibedSensors);
acqSensorDataAccessorMap = containers.Map('KeyType','char','ValueType','any');

% filter activated tasks and parameters
calibratorTasks = calibratorTasks(isTaskScheduled);

%% 1 - Acquire sensor data
% 
% Get stored sensor data or acquire new sensor data for each scheduled
% calibrator task

for cTask = calibratorTasks
    % unwrap cTask
    task = cell2mat(cTask);
    
    % Get or acquire sensor data
    getOrAcquireData(...
        init,task,taskInitParamsMap,...
        acqSensorDataAccessorMap,lastAcqSensorDataAccessorMap);
end

% Save eventual changes of last acquired data accessors to file
save('lastAcqSensorDataAccessorMap.mat','lastAcqSensorDataAccessorMap');

%% 2 - Run the calibrators

% 2.1 - Calibrate the accelerometers gains/offsets
if init.calibrateAccelerometers
    % calibrator task and function
    task = 'accelerometersCalibrator';
    
    % calibrator function
    calibratorH = @(~,taskSpec,path,sensors,parts) ...
        AccelerometersCalibrator.calibrateSensors(...
        calibrationMap,...
        taskSpec,path,sensors,parts); % actual params passed through the func handle
    
    % Calibrate the accelerometers
    runCalibratorOrDiagnosis(...
        init,init.accelerometersCalib,calibratorH,...
        acqSensorDataAccessorMap(task),'acc');
end

% 2.2 - Calibrate the encoders joint offsets
if init.calibrateJointEncoders
    % calibrator task and function
    task = 'jointEncodersCalibrator';
    
    % calibrator function
    calibratorH = @(calParts,taskSpec,path,sensors,parts) ...
        JointEncodersCalibrator.calibrateSensors(...
        init.modelPath,calibrationMap,...
        calParts,taskSpec,path,sensors,parts); % actual params passed through the func handle
    
    % Calibrate the joint encoders
    runCalibratorOrDiagnosis(...
        init,init.jointEncodersCalib,calibratorH,...
        acqSensorDataAccessorMap(task),'joint');
end

% 2.3 - Run diagnosis on acquired data
if init.runDiagnosis
    % Run diagnosis for the each scheduled calibrator task
    for cTask = calibratorTasks
        % unwrap cTask and get task init params
        task = cell2mat(cTask);
        taskInitParams = taskInitParamsMap(task);
        % diagnosis function. Doesn't require 'calibedParts' & 'calibedJointsIdxes'
        diagFuncH = @(~,~,path,sensors,parts) ...
            SensorDiagnosis.runDiagnosis(...
            init.modelPath,calibrationMap,taskInitParams.taskSpecificParams,...
            path,sensors,parts); % actual params passed through the func handle
        % Run diagnosis plotters for all acquired data, so for each acquired data accessor.
        runCalibratorOrDiagnosis(...
            init,taskInitParams,diagFuncH,...
            acqSensorDataAccessorMap(task),calibedSensorsMap(task));
    end
end

% 2.4 - Calibrate the gyroscopes
if init.calibrateGyroscopes
end

% 2.5 - Calibrate the FT sensors gains/offsets
if init.calibrateFTsensors
end

%% Save calibration
if init.saveCalibration
    save('calibrationMap.mat','calibrationMap');
end

%% Uninitialize yarp
yarp.Network.fini();


%%
%%===================================================================================
% Static local functions
%%===================================================================================

% Gets stored sensor data or triggers a sensor data acquisition for the
% scheduled task: acquisition of test data; data for calibrating the joint encoders,
% the accelerometers, or other sensors
function getOrAcquireData(...
    init,task,taskInitParamsMap,...
    acqSensorDataAccessorMap,lastAcqSensorDataAccessorMap)

% [in] init :    application script init config parameters
% [in] task :    calibrator task ('accelerometersCalibrator','jointEncodersCalibrator',...)
% [in] taskInitParamsMap :    subset of config parameters for the scheduled task
% [in/out] acqSensorDataAccessorMap :        acquired data accessors
% [in/out] lastAcqSensorDataAccessorMap :    last instances of acquired data accessors

% unwrap the parameters specific to joint encoders calibration
Init.unWrap(taskInitParamsMap(task));

switch sensorDataAcq{1}
    case 'new'
        % Acquire sensor measurements while moving the joints following
        % a profile defined by the task
        acqSensorDataAccessorMap(task) = SensorDataAcquisition.acquireSensorData(...
            task,taskSpecificParams,init.robotName,init.dataPath,calibedParts);
        % save the acquired data info
        lastAcqSensorDataAccessorMap(task) = acqSensorDataAccessorMap(task);
        
    case 'last'
        if isempty(lastAcqSensorDataAccessorMap)...
                || ~isKey(lastAcqSensorDataAccessorMap,task)
            error(['No data has been acquired yet for the task ' task ' !!']);
        end
        acqSensorDataAccessorMap(task) = lastAcqSensorDataAccessorMap(task);
        
    otherwise
        load([init.dataPath '/dataLogInfo.mat'],'dataLogInfoMap');
        acqSensorDataAccessorMap(task) = dataLogInfoMap.get(sensorDataAcq{:});
end

end


% Harvest the parameters and runs the calibration task
function runCalibratorOrDiagnosis(...
    init,taskInitParams,calibratorFuncH,...
    acqSensorDataAccessor,calibedSensor)

% [in] init :              application script init config parameters
% [in] taskInitParams :    subset of config parameters for the scheduled task
% [in] calibratorFuncH:    calibrator main function handle
% [in] acqSensorDataAccessor :    acquired data accessor
% [in] calibedSensor :            sensor to be calibrated
% [in/out] calibrationMap :       calibration parameters database (accs,joints,...)

% unwrap the parameters specific to the calibration task
Init.unWrap(taskInitParams);

% Get data folder path list for joints calibration on required parts.
% If the prior sensor data acquisition was done in N motion sequences
% (it is the case for calibrating the torso which needs a dedicated
% sequence), we get a folder path per sequence, so N paths.
[dataFolderPathList,calibedPartsList] = ...
    acqSensorDataAccessor.getFolderPaths4calibedSensor(calibedSensor,init.dataPath);

% For each sequence, get the logged sensors list and respective
% supporting parts
[measedSensorLists,measedPartsLists] = acqSensorDataAccessor.getMeasedSensorsParts();

%% calibrate joint encoders. If the torso has to be calibrated, it
% should be before the arms since their orientation depends on the
% torso. In the below loop processing, 'calibrationMap' (input/output)
% is updated at each call to 'calibrateSensors'.
cellfun(@(folderPath,calibedParts,measedSensorList,measedPartsList) ...
    calibratorFuncH(...
    calibedParts,taskSpecificParams,folderPath,...
    measedSensorList,measedPartsList),...
    dataFolderPathList,calibedPartsList,measedSensorLists,measedPartsLists);

end

