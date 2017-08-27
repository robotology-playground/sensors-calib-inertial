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
% joint velocities table [DxN] : data.parsedParams.dqMsRad_<label>
% joint PWM table [DxN]        : data.parsedParams.pwms_<label>
% joint torques table [DxN]    : data.parsedParams.taus_<label>
% 
% Parameter names finishing by 's' are the ones recomputed after resampling
% (refer to 'subSamplingSize' in lowLevTauCtrlCalibratorDevConfig.m config
% file).
% 

% For now, only 1 joint per coupling is supported (first one).
% Get the calibrated joint index as mapped in the motors control board server.
jointIdx = model.jointsDbase.getJointIdxFromCtrlBoard(jointMotorCoupling.coupledJoints(1));

% Get respective torque
tau  = data.parsedParams.taus_state(jointIdx);

switch frictionOrKtau
    case 'friction'
        % get motor velocity to be the x axis variable
        xVar = data.parsedParams.dqMsRad_state(jointIdx);
        
    case 'ktau'
        % get motor PWM to be the x axis variable
        xVar = data.parsedParams.pwms_state(jointIdx);
        
    otherwise
        error('calibrateSensors: unknown calibration type !!');
end

% Fit the model using linear regression in the closed form
% (pseudo-inverse). The regression result is returned in 'thetaPosXvar' and
% 'thetaNegXvar' following the mapping:
% -> thetaPosXvar(1) = fitting model's pos. offset
% -> thetaNegXvar(1) = fitting model's neg. offset
% -> thetaPosXvar(2) = fitting model's pos. slope
% -> thetaNegXvar(2) = fitting model's neg. slope
% 
[thetaPosXvar,thetaNegXvar] = Regressors.normalEquationAsym(xVar',tau');

% Convert theta vector to model parameters (motor calibration
% calibList{i}).
% COUPLING IS NOT SUPPORTED YET

% Create calibration parameters object
motorName = jointMotorCoupling.coupledMotors{1};
calib = MotorTransFunc();

switch frictionOrKtau
    case 'friction'
        % Check that the model is symmetrical
        [KcP, KcN, KvP, KvN] = deal(thetaPosXvar(1),thetaNegXvar(1),thetaPosXvar(2),thetaNegXvar(2));
        if abs(KcP+KcN)>abs(KcP)/100 || abs(KvP-KvN)>abs(KvP)
            warning('calibrateSensors: The friction model is not symmetrical');
        end
        % Run a fitting again but matching a single Kc and a single Kv
        theta = Regressors.normalEquationSym(xVar',tau');
        calib.setFriction(theta(1), theta(2));
        
    case 'ktau'
        % Check that the model is symmetrical
        [KoffP, KoffN, KpwmP, KpwmN] = deal(thetaPosXvar(1),thetaNegXvar(1),thetaPosXvar(2),thetaNegXvar(2));
        if abs(KoffP-KoffN)>1e-3 || abs(KpwmP-KpwmN)>abs(KpwmP)
            warning('calibrateSensors: The Ktau model is not symmetrical');
        end
        % Run a fitting again but matching a single Ktau
        theta = Regressors.normalEquationSym(xVar',tau');
        if abs(theta(1))>1e-3 % Tau offset
            warning('calibrateSensors: There is a torque offset in the model PWM to torque !!');
        end
        % Create calibration parameters object
        calib = MotorTransFunc(jointMotorCoupling.coupledMotors{1});
        calib.setKpwm(theta(2));
        
    otherwise
        error('calibrateSensors: unknown calibration type !!');
end

% Plot fitted model over acquired data.
obj.plotModel(frictionOrKtau,thetaPosXvar,thetaNegXvar,xVar,1000);

%===========================

% We suppose that for each motor we computed a set of calibration parameters,
% wrapped in a list of sets 'calibList' aligned we the list of coupled motors.
% So 'calibList{i}' is the calibration set for the motor i.
% 

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
