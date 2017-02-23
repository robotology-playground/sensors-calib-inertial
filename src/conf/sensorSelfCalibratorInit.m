%====================================================================
% This configuration file defines the main application parameters
%====================================================================

%% Common parameters
robotName = 'icubSim';
dataPath  = '../../data/dumper';
modelPath = '../models/iCubGenova05/iCubFull.urdf';
%calibrationMapFile = '../../data/calibration/calibrationMap_#6.mat';
calibrationMapFile = 'calibrationMap.mat';
saveCalibration = false;


%% Standard or custom calibration
calibrationType = 'standard';

%% standard calibration tasks checklist
runDiagnosis = false;
calibrateAccelerometers = false;
calibrateJointEncoders = true;
calibrateFTsensors = false;
calibrateGyroscopes = false;

%% Custom calibration sequence
% the below structured list defines the tasks sequence and their set of
% parameters.
% 
% customCalibSequence = {...
%     'acquire'...
%     {'profiles'seqConfig','seqCfg1','seqConfig2','seqConfig3'};...
%     'diag'   ,{'seqConfig1','seqConfig3'};...
%     'calibAccs','seqConfig1';...
%     'calibJoints','seqConfig2';...
%     'saveCalib',
%     'diagCmp',{
%     };


%% Sensors diagnosis (only accelerometers for now)

% define the robot limb holding the sensors on which we run the diagnosis.
diagnosedParts = {'left_leg'};

% Fine selection of the accelerometers:
% Select (set to 'true') the accelerometers to analyse through the respective indexes.
% 
% (Part)           (inertial MTB boards)
% 
%                  (upper)       (forearm)      (hand)
% left_arm :       1b10..1b13    1b8..1b9       1b7
% right_arm:       2b10..2b13    2b8..2b9       2b7
% mtbSensorAct:      10....13      8....9         7
%                  (upper)       (lower)        (foot)
% left_leg :       10b1..10b7    10b8..10b11    10b12,10b13
% right_leg:       11b1..11b7    11b8..11b11    11b12,11b13
% mtbSensorAct idx:   1.....7       8.....11       12,   13
% 
% head     :       head_imu 3D accelerometer
% mtbSensorAct idx:  1
% 
% torso    :       9b7..9b10
% mtbSensorAct idx:  7....10
% 
% some sensors are de-activated because of faulty behaviour
mtbSensorAct.left_arm = [10:13 8:9 7];
mtbSensorAct.right_arm = [10:13 8:9 7];
mtbSensorAct.left_leg = 1:13;
mtbSensorAct.right_leg = 1:13;
mtbSensorAct.torso = 7:10;
mtbSensorAct.head = 1;

% Save generated figures: if this flag is set to true, all data is saved and figures 
% printed in a new folder indexed by a unique iteration number. Log
% classification information are saved in text format for easier search from
% a file explorer.
logTest = true;

% Sensor data acquisition: ['new'|'last'|<id>]
sensorDataAcq = {'new'};

% wrap parameters
sensorDiagnosis = struct('diagnosedParts',{diagnosedParts},'mtbSensorAct',mtbSensorAct,'logTest',logTest,'sensorDataAcq',{sensorDataAcq});
clear diagnosedParts mtbSensorAct logTest sensorDataAcq;

%% MTB/IMU accelerometers gains/offsets calibration

% Calibrated parts:
% Only the accelerometers from these parts (limbs) will be calibrated
calibedParts = {'left_leg','right_leg'};

% some sensors are de-activated because of faulty behaviour
mtbSensorAct.left_arm = [10:13 8:9 7];
mtbSensorAct.right_arm = [10:13 8:9 7];
mtbSensorAct.left_leg = 1:13;
mtbSensorAct.right_leg = 1:13;
mtbSensorAct.torso = 7:10;
mtbSensorAct.head = 1;

% Sensor data acquisition: ['new'|'last'|<id>]
sensorDataAcq = {'new'};

% wrap parameters
accelerometersCalib = struct('calibedParts',{calibedParts},'mtbSensorAct',mtbSensorAct,'sensorDataAcq',{sensorDataAcq});
clear calibedParts mtbSensorAct sensorDataAcq;


%% Joint encoders offsets calibration

% Calibrated parts:
% Only the joint encoders from these parts (limbs) will be calibrated
calibedParts = {'left_leg','right_leg'};

% Fine selection of joint encoders:
% Select the joints to calibrate through the respective indexes. These indexes match 
% the joint names listed below, as per the joint naming convention described in 
% 'http://wiki.icub.org/wiki/ICub_Model_naming_conventions', except for the torso.
%
%      shoulder pitch roll yaw   |   elbow   |   wrist prosup roll yaw   |  
% arm:          0     1    2     |   3       |         4      5    6     |
%
%      hip      pitch roll yaw   |   knee    |   ankle pitch  roll       |  
% leg:          0     1    2     |   3       |         4      5          |
%
%               pitch roll yaw   |
% torso:        0     1    2     |
%
%               pitch roll yaw   |
% head:         0     1    2     |
%
%=================================================================
% !!! Below joint indexes will be ignored for parts not defined in
% 'calibedParts' !!!
%=================================================================
calibedJointsIdxes.left_arm = 0:3;
calibedJointsIdxes.right_arm = 0:3;
calibedJointsIdxes.left_leg = 0:5;
calibedJointsIdxes.right_leg = 0:5;
calibedJointsIdxes.torso = 0:2;
calibedJointsIdxes.head = 0:2;

% Sensor data acquisition: ['new'|'last'|<id>]
sensorDataAcq = {'calibrator',7};

% wrap parameters
jointEncodersCalib = struct('calibedParts',{calibedParts},'calibedJointsIdxes',calibedJointsIdxes,'sensorDataAcq',{sensorDataAcq});
clear calibedParts calibedJointsIdxes sensorDataAcq;

%% FT sensors gains/offsets calibration (TBD)

ftSensorsCalib = struct();
gyroscopesCalib = struct();

