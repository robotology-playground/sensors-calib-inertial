function modelParams = buildModelParams(obj,...
    measedSensorList,measedPartsList,...
    calibedParts,calibedJointsIdxes,calibedJointsDq0,...
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

jointsToCalibrate.ctrledJoints = {};
jointsToCalibrate.calibedJointsDq0 = {};
jointsToCalibrate.jointsDofs = {};
jointsToCalibrate.ctrledJointsIdxes = {}; % element index on the data from yarp port
jointsToCalibrate.calibedJointsIdxes = {}; % subset within the controlled joints

% 'jointsToCalibrate' holds information for measured and calibrated
% joints. Use the list of parts associated to measured joint encoders
parts = [measedPartsList{ismember(measedSensorList,'joint')}];

% Preset some input parameters
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
    jointList = obj.jointsDbase.getJointNames(parts{i});
    jointsToCalibrate.ctrledJoints{i} = jointList;
    jointsToCalibrate.calibedJointsDq0{i} = obj.jointsDbase.getCalibedJointsDq0(jointList);
    jointsToCalibrate.jointsDofs{i} = obj.jointsDbase.getTotalJointDoF(jointList);
    jointsToCalibrate.ctrledJointsIdxes{i} = obj.jointsDbase.yarpPortJointIdxes(jointList);
    jointsToCalibrate.calibedJointsIdxes{i} = obj.jointsDbase.yarpPortCalibedJointIdxes(jointList);
    jointsToCalibrate.mapIdx(parts{i}) = i;
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

activeSensorLabels = {};

% 'mtbSensorXXX' and 'mtxSensorXXX' hold information for measured inertial
% joints. Use the list of parts associated to measured accelerometers and
% IMUs.
parts = [measedPartsList{ismember(measedSensorList,{'acc','imu'})}];
for i = 1:length(parts)
    activeSensorLabels{i} = obj.sensorsDbase.getSensorlabels(parts{i});
end

% Save parameters to output structure
modelParams.accMeasedParts = parts; % parts for measured inertial sensors
modelParams.activeSensorLabels = activeSensorLabels;

end

%===== Local functions ========

function idxes = sensorShortCodes2Idxes(part,part2mtbNum,mtbSensorAct,mtbSensorCodes)

codes2idxesMap = containers.Map(mtbSensorCodes,num2cell(1:numel(mtbSensorCodes)));

codes = arrayfun(...
    @(shortCode) [part2mtbNum(part) num2str(shortCode)],...
    mtbSensorAct,...
    'UniformOutput',false);

idxes = cell2mat(codes2idxesMap.values(codes));

end
