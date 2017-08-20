function calibrateSensors(...
    dataPath,~,measedSensorList,measedPartsList,...
    model,taskSpecificParams)

% Get calibration map
calibrationMap = model.calibrationMap;

% Unwrap task specific parameters, defines:
% - frictionOrKtau       -> = 'friction' for friction calibration
%                           = 'ktau' for ktau calibration
% - jointMotorCoupling   -> label for retrieving the currently calibrated
%                           joint/motor group info. Refer to jointsDbase
%                           class interface.
% 
% a joint/motor group info is formatted as follows:
% group.coupledJoints : ordered list of joint names (size 1 or n)
% group.coupledMotors : ordered list of MotorFriction object handles (same size)
% group.T             : 3x3 matrix or integer 1
% 
Init.unWrap(taskSpecificParams);

%% build input data for calibration
%
% build sensor data parser
dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jointMotorCoupling.coupledJoints);

plot = false; loadJointPos = true;
data = SensorsData(dataPath,'',obj.subSamplingSize,...
    obj.timeStart,obj.timeStop,plot,calibrationMap);
data.buildInputDataSet(loadJointPos,dataLoadingParams);

%===========================
% Implement the fitting process in this section. joint encoder velocities
% and torques, motor PWM measurements can be retrieved from tha 'data'
% structure:
% 
% For N samples of dimension D (group of D coupled joints), we get:
% 
% joint velocities table [DxN] : data.parsedParams.dqMs_<label>
% joint PWM table [DxN]        : data.parsedParams.pwms_<label>
% joint torques table [DxN]    : data.parsedParams.taus_<label>
% 
% Paramter names finishing by 's' are the ones recomputed after resampling
% (refer to 'subSamplingSize' in lowLevTauCtrlCalibratorDevConfig.m config
% file).
% 



% We suppose that for each motor we computed a set of calibration parameters,
% wrapped in a list of sets 'calibList' aligned we the list of coupled motors.
% So 'calibList{i}' is the calibration set for the motor i.
% 
% Plot fitted model over acquired data.
obj.plotModel(frictionOrKtau,data,calibList);

%===========================

% Save calibrated parameters into 'calibrationMap'.
% 
for cMotorLabelCalib = [jointMotorCoupling.coupledMotors;calibList]
    % extract motor label and calibration
    motorLabel = cMotorLabelCalib{1};
    calib = cMotorLabelCalib{2};
    
    % Save parameters to the mapper
    % (add or overwrite element in the map)
    calibrationMap(motorLabel) = calib;
end

end
