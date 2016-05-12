%% DEBUG
%jointsToCalibrate.parts = {'left_arm','right_arm','left_leg','right_leg'};

%% macros for repetitive names and codes between left and right parts
%
jointsToCalibrate_arm = @(side) {[side '_shoulder_pitch'],[side '_shoulder_roll'],[side '_shoulder_yaw'],[side '_elbow']};
jointsIdxes_arm = '1:4';

jointsToCalibrate_leg = @(side) {[side '_hip_pitch'],[side '_hip_roll'],[side '_hip_yaw'], ...
                                 [side '_knee'],[side '_ankle_pitch'],[side '_ankle_roll']};
jointsIdxes_leg = '1:6';
                             
mtbSensorCodes_arm = @(mtbNum) {[mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12'],[mtbNum 'b13'], ...
                                [mtbNum 'b8'],[mtbNum '1b9'], ...
                                [mtbNum 'b7']};

mtbSensorCodes_leg = @(mtbNum) {[mtbNum 'b1'],[mtbNum 'b2'], ...
                                [mtbNum 'b3'],[mtbNum 'b4'], ...
                                [mtbNum 'b5'], ...
                                [mtbNum 'b6'],[mtbNum 'b7'], ...
                                [mtbNum 'b8'],[mtbNum 'b9'], ...
                                [mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12']};

mtbSensorLink_arm = @(side) {[side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_forearm'],[side '_forearm'] ...
                             [side '_hand']};

mtbSensorLink_leg = @(side) {[side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_foot']};

segments_leg = @(side) {[side '_upper_leg'],[side '_lower_leg'],[side '_foot']};
segments_arm = @(side) {[side '_upper_arm'],[side '_forearm'],[side '_hand']};

%% define the joints to calibrate
%
jointsToCalibrate_left_arm = jointsToCalibrate_arm('l');
jointsToCalibrate_right_arm = jointsToCalibrate_arm('r');
jointsToCalibrate_left_leg = jointsToCalibrate_leg('l');
jointsToCalibrate_right_leg = jointsToCalibrate_leg('r');
jointsToCalibrate_torso = {'torso_pitch','torso_roll','torso_yaw'};
jointsToCalibrate_head = {'neck_pitch', 'neck_roll', 'neck_yaw'};

jointsDofs_left_arm = 16;
jointsDofs_right_arm = 16;
jointsDofs_left_leg = 6;
jointsDofs_right_leg = 6;
jointsDofs_torso = 3;
jointsDofs_head = 6;

jointsIdxes_left_arm = jointsIdxes_arm;
jointsIdxes_right_arm = jointsIdxes_arm;
jointsIdxes_left_leg = jointsIdxes_leg;
jointsIdxes_right_leg = jointsIdxes_leg;
jointsIdxes_torso = '1:3';
jointsIdxes_head = '1:3';

jointsInitOffsets_left_arm = [0 0 0 0];
jointsInitOffsets_right_arm = [0 0 0 0];
jointsInitOffsets_left_leg = [0 0 0 0 0 0];
%jointsInitOffsets_left_leg = [-0.0021   -0.0346    0.0426    0.3098    0.2366    0.0751];
jointsInitOffsets_right_leg = [0 0 0 0 0 0];
jointsInitOffsets_torso = [0 0 0];
jointsInitOffsets_head = [0 0 0];

jointsDq0_left_arm = [0 0 0 0];
jointsDq0_right_arm = [0 0 0 0];
jointsDq0_left_leg = [0 0 0 0 0 0];
jointsDq0_right_leg = [0 0 0 0 0 0];
jointsDq0_torso = [0 0 0];
jointsDq0_head = [0 0 0];

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

%% some sensor are inverted in the model with respect to how are mounted on
mtbInvertedFrames_left_arm  = {false,false,false,false,false,false,false};
mtbInvertedFrames_right_arm = {false,false,false,false,false,false,false};
mtbInvertedFrames_left_leg  = {false,false,  true,true  ,false,false,false,  true  ,false,false,false,  true};
mtbInvertedFrames_right_leg = {false,false,  true,true  ,false,false,false,  true  ,false,false,false,  true};
mtbInvertedFrames_torso = {false,false,false,false};
mtbInvertedFrames_head = {false};

%% some sensors are de-activated because of faulty behaviour, bad calibration or wrong frame definition
mtbSensorAct_left_arm(1:7) = {true};

mtbSensorAct_right_arm(1:7) = {true};

mtbSensorAct_left_leg = ...
    {false,false, ...
    true,true, ...
    false, ...
    true,true, ...
    true,false,   ...
    false,false,   ...
    true};

mtbSensorAct_right_leg = mtbSensorAct_left_leg;

mtbSensorAct_torso(1:3) = {true};

mtbSensorAct_head(1) = {true};


%% Build access lists
%
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
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
    eval(['jointsToCalibrate.mtbInvertedFrames{' num2str(i) '} = mtbInvertedFrames_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.jointsDofs{' num2str(i) '} = jointsDofs_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.jointsIdxes{' num2str(i) '} = jointsIdxes_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorCodes_list{' num2str(i) '} = mtbSensorCodes_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorLink_list{' num2str(i) '} = mtbSensorLink_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorAct_list{' num2str(i) '} = mtbSensorAct_' jointsToCalibrate.parts{i} ';']);
    eval(['mtxSensorType_list{' num2str(i) '} = mtxSensorType_' jointsToCalibrate.parts{i} ';']);
end
