function calibrateSensors(...
    dataPath,calibedParts,measedSensorList,measedPartsList,...
    model,taskSpecificParams)

% Get calibration map
calibrationMap = model.calibrationMap;

% Unwrap task specific parameters, defines:
% - frictionOrKtau       -> = 'friction' for friction calibration
%                           = 'ktau' for ktau calibration
% - jointMotorGroupLabel -> label for retrieving the currently calibrated
%                           joint/motor group info. Refer to jointsDbase
%                           class interface.
% 
% a joint/motor group info is formatted as follows:
% group.coupledJoints : ordered list of joint names (size 1 or n)
% group.coupledMotors : ordered list of MotorFriction object handles (same size)
% group.T             : 3x3 matrix or integer 1
% 
Init.unWrap(taskSpecificParams);

% Advanced interface parameters:
% - timeStart, timeStop, subSamplingSize
run lowLevTauCtrlCalibratorDevConfig;

%% build input data for calibration
%
% build sensor data parser
jtMotGrpInfo = model.jointsDbase.getJmGrpInfo(jointMotorGroupLabel);

dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jtMotGrpInfo.coupledJoints);

plot = false; loadJointPos = true;
data = SensorsData(dataPath,'',subSamplingSize,...
    timeStart,timeStop,plot,calibrationMap);
data.buildInputDataSet(loadJointPos,dataLoadingParams);

%===========================
% Implement the fitting process in this section. joint encoder velocities
% and torques, motor PWM measurements can be retrieved from tha 'data'
% structure:
% 
% For N samples of dimension D (group of D coupled joints), we get:
% 
% joint velocities table [DxN] : data.parsedParams.dqs_<label>
% joint PWM table [DxN]        : data.parsedParams.pwms_<label>
% joint torques table [DxN]    : data.parsedParams.taus_<label>
% 
% Paramter names finishing by 's' are the ones recomputed after resampling
% (refer to 'subSamplingSize' in lowLevTauCtrlCalibratorDevConfig.m config
% file).
% 




%===========================

% Merge new calibrated joint offsets with old 'calibrationMap'.
% The result matrix optimalDq has the same format as Dq and Dq0.
% Dq0 results from the concatenation of the modelParams.jointsToCalibrate.calibedJointsDq0
% matrices.
[~,calibedPartsIdxes] = ismember(dataLoadingParams.calibedParts,dataLoadingParams.jointMeasedParts);

% Split computed offsets matrix into part wise cells
calib = mat2cell(averageOptimalDq,lengths(dataLoadingParams.jointsToCalibrate.calibedJointsDq0{calibedPartsIdxes}));

for iter = calibedPartsIdxes
    mapKey = strcat('jointsOffsets_',dataLoadingParams.jointMeasedParts{iter}); % set map key
    % get current value or set a default one (zeros)
    if isKey(calibrationMap,mapKey)
        mapValue = calibrationMap(mapKey); % get current value
    else
        mapValue = zeros(dataLoadingParams.jointsToCalibrate.jointsDofs{iter},1); % init default value
    end
    mapValue(dataLoadingParams.jointsToCalibrate.calibedJointsIdxes{iter}) = ...
        mapValue(dataLoadingParams.jointsToCalibrate.calibedJointsIdxes{iter}) + calib{iter}; % add calibrated values
    calibrationMap(mapKey) = mapValue; % add or overwrite element in the map
end

end
