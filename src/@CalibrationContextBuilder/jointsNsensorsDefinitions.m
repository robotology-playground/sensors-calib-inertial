function modelParams = jointsNsensorsDefinitions(...
    measedSensorList,measedPartsList,...
    calibedParts,calibedJointsIdxes,calibedJointsDq0,...
    mtbSensorAct)
%% Joints and Sensors selection
%
% - Select the joints to calibrate through the respective indexes in the port data
% - Define parameters for all joints (calibrated or not)
% - Select activated sensors

%% macros for repetitive names and codes between left and right parts
%

mtbSensorCodes_arm = @(mtbNum) {...
    [mtbNum 'b10'],[mtbNum 'b11'], ...
    [mtbNum 'b12'],[mtbNum 'b13'], ...
    [mtbNum 'b8'],[mtbNum 'b9'], ...
    [mtbNum 'b7']};

mtbSensorCodes_leg = @(mtbNum) {...
    [mtbNum 'b1'],[mtbNum 'b2'], ...
    [mtbNum 'b3'],[mtbNum 'b4'], ...
    [mtbNum 'b5'], ...
    [mtbNum 'b6'],[mtbNum 'b7'], ...
    [mtbNum 'b8'],[mtbNum 'b9'], ...
    [mtbNum 'b10'],[mtbNum 'b11'], ...
    [mtbNum 'b12'],[mtbNum 'b13']};

mtbSensorLink_arm = @(side) {...
    [side '_upper_arm'],[side '_upper_arm'], ...
    [side '_upper_arm'],[side '_upper_arm'], ...
    [side '_forearm'],[side '_forearm'] ...
    [side '_forearm']};

mtbSensorLink_leg = @(side) {...
    [side '_upper_leg'],[side '_upper_leg'], ...
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
% from class @RobotModel

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

%% Build access lists for joints information
%

jointsToCalibrate.ctrledJoints = {};
jointsToCalibrate.calibedJointsDq0 = {};
jointsToCalibrate.partSegments = {};
jointsToCalibrate.jointsDofs = {};
jointsToCalibrate.ctrledJointsIdxes = {}; % element index on the data from yarp port
jointsToCalibrate.calibedJointsIdxes = {}; % subset within the controlled joints

% 'jointsToCalibrate' holds information for measured and calibrated
% joints. Use the list of parts associated to measured joint encoders
parts = [measedPartsList{ismember(measedSensorList,'joint')}];

% Preset some input parameters
parts = [measedPartsList{ismember(measedSensorList,'joint')}];
if isempty(calibedParts)
    for cPart = parts
        part = cell2mat(cPart);
        calibedJointsIdxes.(part) = [];
        calibedJointsDq0.(part) = [];
    end
end

% Build 'jointsToCalibrate'
jointsToCalibrate.mapIdx = containers.Map('KeyType','char','ValueType','uint8');
for i = 1:length(parts)
    jointsToCalibrate.ctrledJoints{i} = RobotModel.jointsListFromPart(parts{i});
    eval(['jointsToCalibrate.calibedJointsDq0{' num2str(i) '} = calibedJointsDq0.' parts{i} ';']);
    eval(['jointsToCalibrate.partSegments{' num2str(i) '} = segments_' parts{i} ';']);
    eval(['jointsToCalibrate.jointsDofs{' num2str(i) '} = jointsDofs_' parts{i} ';']);
    eval(['jointsToCalibrate.ctrledJointsIdxes{' num2str(i) '} = 1:' num2str(length(jointsToCalibrate.ctrledJoints{i})) ';']);
    eval(['jointsToCalibrate.calibedJointsIdxes{' num2str(i) '} = calibedJointsIdxes.' parts{i} ';']);
    jointsToCalibrate.mapIdx(parts{i}) = i;
end

% Process the selection for the structure 'jointsToCalibrate' definition
for i = 1:length(parts)
    jointsToCalibrate.calibedJointsDq0{i}=jointsToCalibrate.calibedJointsDq0{i}(jointsToCalibrate.calibedJointsIdxes{i});
end

% Save parameters to output structure
modelParams.jointsToCalibrate = jointsToCalibrate;
modelParams.calibedParts = calibedParts; % parts for calibrated joint encoders
modelParams.jointMeasedParts = parts;    % parts for measured joint encoders

%% Build access lists for inertial sensors information
%

mtbSensorCodes_list = {};
mtbSensorLink_list = {};
mtbSensorAct_list = {};
mtxSensorType_list = {};

% 'mtbSensorXXX' and 'mtxSensorXXX' hold information for measured inertial
% joints. Use the list of parts associated to measured accelerometers and
% IMUs.
parts = [measedPartsList{ismember(measedSensorList,{'acc','imu'})}];
for i = 1:length(parts)
    eval(['mtbSensorCodes_list{' num2str(i) '} = mtbSensorCodes_' parts{i} ';']);
    eval(['mtbSensorLink_list{' num2str(i) '} = mtbSensorLink_' parts{i} ';']);
    eval(['mtbSensorAct_list{' num2str(i) '} = mtbSensorAct.' parts{i} ';']);
    eval(['mtxSensorType_list{' num2str(i) '} = mtxSensorType_' parts{i} ';']);
end

% Save parameters to output structure
modelParams.accMeasedParts = parts; % parts for measured inertial sensors
modelParams.mtbSensorCodes_list = mtbSensorCodes_list;
modelParams.mtbSensorLink_list = mtbSensorLink_list;
modelParams.mtbSensorAct_list = mtbSensorAct_list;
modelParams.mtxSensorType_list = mtxSensorType_list;

