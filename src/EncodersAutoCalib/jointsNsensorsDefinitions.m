%% DEBUG
% jointsToCalibrate.parts = {'left_arm','right_arm','left_leg','right_leg'};
%
% variables to change in order to define a subset of joints to 
% calibrate:
% jointsToCalibrate_leg
% jointsInitOffsets_left_leg, jointsInitOffsets_right_leg
% jointsDq0_left_leg, jointsDq0_right_leg

%%%================================== INTERFACE START ==============================
%% Select the joints to calibrate through the respective indexes in the port data
%
jointsIdxes_left_arm = '1:4';
jointsIdxes_right_arm = '1:4';
jointsIdxes_left_leg = '1:6';
jointsIdxes_right_leg = '1:6';
jointsIdxes_torso = '1:3';
jointsIdxes_head = '1:3';

%% Define parameters for all joints (calibrated or not)
%
% Simulated joint encoders offsets
jointsInitOffsets_left_arm = [0 0 0 0];
jointsInitOffsets_right_arm = [0 0 0 0];
jointsInitOffsets_left_leg = [0 0 0 0 0 0];
jointsInitOffsets_right_leg = [0 0 0 0 0 0];
jointsInitOffsets_torso = [0 0 0];
jointsInitOffsets_head = [0 0 0];

% Optimization starting point
jointsDq0_left_arm = [0 0 0 0];
jointsDq0_right_arm = [0 0 0 0];
jointsDq0_left_leg = [0 0 0 0 0 0];
jointsDq0_right_leg = [0 0 0 0 0 0];
jointsDq0_torso = [0 0 0];
jointsDq0_head = [0 0 0];

% pre-computed optimal joint offsets
averageOptimalDq = 0;

%% some sensors are de-activated because of faulty behaviour, bad calibration or wrong frame definition
mtbSensorAct_left_arm(1:7) = {true};
mtbSensorAct_left_arm([3 5:7]) = {false};

mtbSensorAct_right_arm(1:7) = {true};
mtbSensorAct_right_arm([1 3 5]) = {false};

mtbSensorAct_left_leg(1:13) = {true};
mtbSensorAct_left_leg(12:13) = {false};

mtbSensorAct_right_leg(1:13) = {true};
mtbSensorAct_right_leg([6 7 12:13]) = {false};

mtbSensorAct_torso(1:4) = {false};

mtbSensorAct_head(1) = {true};

%%%================================== INTERFACE END ================================

%% macros for repetitive names and codes between left and right parts
%
jointsToCalibrate_arm = @(side) {[side '_shoulder_pitch'],[side '_shoulder_roll'],[side '_shoulder_yaw'],[side '_elbow']};

jointsToCalibrate_leg = @(side) {[side '_hip_pitch'],[side '_hip_roll'],[side '_hip_yaw'], ...
                                 [side '_knee'],[side '_ankle_pitch'],[side '_ankle_roll']};

mtbSensorCodes_arm = @(mtbNum) {[mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12'],[mtbNum 'b13'], ...
                                [mtbNum 'b8'],[mtbNum 'b9'], ...
                                [mtbNum 'b7']};

mtbSensorCodes_leg = @(mtbNum) {[mtbNum 'b1'],[mtbNum 'b2'], ...
                                [mtbNum 'b3'],[mtbNum 'b4'], ...
                                [mtbNum 'b5'], ...
                                [mtbNum 'b6'],[mtbNum 'b7'], ...
                                [mtbNum 'b8'],[mtbNum 'b9'], ...
                                [mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12'],[mtbNum 'b13']};

mtbSensorLink_arm = @(side) {[side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_forearm'],[side '_forearm'] ...
                             [side '_forearm']};

mtbSensorLink_leg = @(side) {[side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_foot'],[side '_foot']};

segments_leg = @(side) {[side '_upper_leg'],[side '_lower_leg'],[side '_foot']};
segments_arm = @(side) {[side '_upper_arm'],[side '_forearm'],[side '_hand']};

%% Build lists for left and right parts

% joints names
jointsToCalibrate_left_arm = jointsToCalibrate_arm('l');
jointsToCalibrate_right_arm = jointsToCalibrate_arm('r');
jointsToCalibrate_left_leg = jointsToCalibrate_leg('l');
jointsToCalibrate_right_leg = jointsToCalibrate_leg('r');
jointsToCalibrate_torso = {'torso_pitch','torso_roll','torso_yaw'};
jointsToCalibrate_head = {'neck_pitch', 'neck_roll', 'neck_yaw'};

% joints DoF
jointsDofs_left_arm = 16;
jointsDofs_right_arm = 16;
jointsDofs_left_leg = 6;
jointsDofs_right_leg = 6;
jointsDofs_torso = 3;
jointsDofs_head = 6;

% We define a segment i as a link for which parent joint i and joint i+1 axis 
% are not concurrent. For instance 'root_link', 'r_upper_leg', 'r_lower_leg', 
% 'r_foot' are segments of the right leg. 'r_hip_1', 'r_hip2' and r_hip_3' are 
% part of the 3 DoF hip joint.
segments_left_leg = segments_leg('l');
segments_right_leg = segments_leg('r');
segments_left_arm = segments_arm('l');
segments_right_arm = segments_arm('r');
segments_torso = {'chest'};
segments_head = {'head'};

%% define the sensor codes and links they are attached to
%
mtbSensorCodes_left_arm =  mtbSensorCodes_arm('1');

mtbSensorCodes_right_arm = mtbSensorCodes_arm('2');

mtbSensorCodes_left_leg =  mtbSensorCodes_leg('10');

mtbSensorCodes_right_leg = mtbSensorCodes_leg('11');

mtbSensorCodes_torso =  {'9b7','9b8', ...
                         '9b9','9b10'};

mtbSensorCodes_head = {'1x1'};


mtbSensorLink_left_arm = mtbSensorLink_arm('l');

mtbSensorLink_right_arm = mtbSensorLink_arm('r');

mtbSensorLink_left_leg = mtbSensorLink_leg('l');

mtbSensorLink_right_leg = mtbSensorLink_leg('r');

mtbSensorLink_torso = {'chest'};

mtbSensorLink_head = {'head'};

%% sensor types: MTB acc., MTI acc.(imu)
mtxSensorType_left_arm(1:7) = {'inertialMTB'};
mtxSensorType_right_arm = mtxSensorType_left_arm;
mtxSensorType_left_leg(1:13) = {'inertialMTB'};
mtxSensorType_right_leg = mtxSensorType_left_leg;
mtxSensorType_torso(1:4) = {'inertialMTB'};
mtxSensorType_head(1) = {'inertialMTI'};

%% Build access lists
%
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {}; % simulated joint encoders offsets
jointsToCalibrate.jointsDq0 = {};
jointsToCalibrate.partSegments = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};
mtbSensorAct_list = {};
mtxSensorType_list = {};

for i = 1:length(jointsToCalibrate.parts)
    eval(['jointsToCalibrate.partJoints{' num2str(i) '} = jointsToCalibrate_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.partJointsInitOffsets{' num2str(i) '} = jointsInitOffsets_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.jointsDq0{' num2str(i) '} = jointsDq0_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.partSegments{' num2str(i) '} = segments_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.jointsDofs{' num2str(i) '} = jointsDofs_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.jointsIdxes{' num2str(i) '} = jointsIdxes_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorCodes_list{' num2str(i) '} = mtbSensorCodes_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorLink_list{' num2str(i) '} = mtbSensorLink_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorAct_list{' num2str(i) '} = cell2mat(mtbSensorAct_' jointsToCalibrate.parts{i} ');']);
    eval(['mtxSensorType_list{' num2str(i) '} = mtxSensorType_' jointsToCalibrate.parts{i} ';']);
end

% Process the selection for the structure 'jointsToCalibrate' definition
for i = 1:length(jointsToCalibrate.parts)
    jointsToCalibrate.partJoints{i}=jointsToCalibrate.partJoints{i}(str2num(jointsToCalibrate.jointsIdxes{i}));
    jointsToCalibrate.partJointsInitOffsets{i}=jointsToCalibrate.partJointsInitOffsets{i}(str2num(jointsToCalibrate.jointsIdxes{i}));
    jointsToCalibrate.jointsDq0{i}=jointsToCalibrate.jointsDq0{i}(str2num(jointsToCalibrate.jointsIdxes{i}));
end

ModelParams.jointsToCalibrate = jointsToCalibrate;
ModelParams.mtbSensorCodes_list = mtbSensorCodes_list;
ModelParams.mtbSensorLink_list = mtbSensorLink_list;
ModelParams.mtbSensorAct_list = mtbSensorAct_list;
ModelParams.mtxSensorType_list = mtxSensorType_list;

