function modelParams = buildModelParams(obj,...
    measedSensorList,measedPartsList,...
    calibedParts,calibedJointsIdxes,...
    mtbSensorAct)
%buildModelParams Build old interface structure
%   Build old interface structure such that RobotModel class
%   introduction doesn't impact the calibrators and the yarp data
%   parsing current design (for non-regression tests purpose).

%% save joints and sensors databases from model
modelParams.jointsDbase = obj.jointsDbase;
modelParams.sensorsDbase = obj.sensorsDbase;

%% Build access lists for joints information
%

% 'jointsToCalibrate' holds information for measured and calibrated
% joints. Use the list of parts associated to measured joint encoders
parts = [measedPartsList{ismember(measedSensorList,'joint')}];

% Preset some input parameters
if isempty(calibedParts)
    for cPart = parts
        part = cell2mat(cPart);
        calibedJointsIdxes.(part) = [];
    end
end

% Build 'jointsToCalibrate'
jointsToCalibrate.ctrledJoints = cell(1,length(parts));
jointsToCalibrate.calibedJointsDq0 = cell(1,length(parts));
jointsToCalibrate.jointsDofs = cell(1,length(parts));
jointsToCalibrate.ctrledJointsIdxes = cell(1,length(parts)); % element index on the data from yarp port
jointsToCalibrate.calibedJointsIdxes = cell(1,length(parts)); % subset within the controlled joints

jointsToCalibrate.mapIdx = containers.Map('KeyType','char','ValueType','uint8');
for i = 1:length(parts)
    jointList = obj.jointsDbase.getJointNames(parts{i});
    jointsToCalibrate.ctrledJoints{i} = jointList;
    jointsToCalibrate.calibedJointsDq0{i} = obj.jointsDbase.getJointsMaxCalibDq0(jointList);
    jointsToCalibrate.jointsDofs{i} = obj.jointsDbase.getTotalJointDoF(jointList);
    jointsToCalibrate.ctrledJointsIdxes{i} = 1:length(jointList); % TO BE FIXED. the indexes here should match those in the app GUI and YARP indexes
    jointsToCalibrate.calibedJointsIdxes{i} = calibedJointsIdxes.(parts{i});
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

if isempty(mtbSensorAct)
    mtbSensorAct.left_arm = [10:13 8:9 7];
    mtbSensorAct.right_arm = [10:13 8:9 7];
    mtbSensorAct.left_leg = 1:13;
    mtbSensorAct.right_leg = 1:13;
    mtbSensorAct.torso = 7:10;
    mtbSensorAct.head = 1;
end

% Use the list of parts associated to measured accelerometers and
% IMUs.
parts = [measedPartsList{ismember(measedSensorList,{'acc','imu'})}];

activeSensorLabels = cell(1,length(parts));

for i = 1:length(parts)
    activeSensorLabels{i} = obj.sensorsDbase.getSensorlabels(parts{i},mtbSensorAct.(parts{i}));
end

% Save parameters to output structure
modelParams.accMeasedParts = parts; % parts for measured inertial sensors
modelParams.activeSensorLabels = activeSensorLabels;

end
