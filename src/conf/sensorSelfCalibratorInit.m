%====================================================================
% This configuration file defines the main application parameters
%====================================================================

%% Common parameters
robotName = 'icubSim';
dataPath  = '../../data/calibration/dumper';
modelPath = '../models/iCubGenova05/iCubFull.urdf';

%% Standard or custom calibration
calibrationType = 'standard';

%% standard calibration tasks checklist
runDiagnosis = false;
calibrateAccelerometers = false;
calibrateIMU = false;
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

%% Accelerometers/IMU gains/offsets calibration


%% Joint encoders offsets calibration

% Calibrated parts:
% Only the joint encoders from these parts (limbs) will be calibrated
calibedParts = {'left_leg','torso','right_leg'};

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

