function calibrateSensors(obj,...
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

% Get the coupling info from the motor name. Each motor belongs to a single coupling set
jointMotorCoupling = cell(model.jointsDbase.getJMcouplings('motors',{motorName})){1};

%% build input data for calibration
%
% build sensor data parser
dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jointMotorCoupling.coupledJoints);

plot = false; loadJointPos = true;
data = SensorsData(dataPath,obj.subSamplingSize,...
    obj.timeStart,obj.timeStop,plot,calibrationMap);
data.buildInputDataSet(loadJointPos,dataLoadingParams);

%% Fitting process implementation.
% Joint encoder velocities and torques, motor PWM measurements can be
% retrieved from tha 'data' structure:
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

% Get the calibrated joint index as mapped in the motors control board server.
%jointIdxes = model.jointsDbase.getAxesIdxesFromCtrlBoard('joints',jointMotorCoupling.coupledJoints);
[~,motorIdx] = ismember(motorName,jointMotorCoupling.coupledMotors);

% Get respective torques (matrix 6xNsamples)
tauJoints  = data.parsedParams.(['taus_' jointMotorCoupling.part '_state']);
% We have the coupling matrix Tm2j (motor to joint) and:
% dq_j = Tm2j * dq_m
% Tau_j = Tm2j^{-t} * Tau_m <=> Tau_m = Tm2j^t * Tau_j
% 
% which is also applicable for a gearbox ratio:
% if   dq_j = Gm2j * dq_m
% then Tau_m = Gm2j^t * Tau_j.
% Since Gm2j is a diagonal matrix, then Tau_m = Gm2j * Tau_j.
tauMotor = jointMotorCoupling.gearboxDqM2Jratios{motorIdx} * jointMotorCoupling.Tm2j(:,motorIdx)' * tauJoints;

switch frictionOrKtau
    case 'friction'
        % get motor velocity to be the x axis variable
        xVar = data.parsedParams.(['dqMsRad_' jointMotorCoupling.part '_state'])(motorIdx,:);
        
    case 'ktau'
        % get motor PWM to be the x axis variable
        xVar = data.parsedParams.(['pwms_' jointMotorCoupling.part '_state'])(motorIdx,:);
        
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
[thetaPosXvar,thetaNegXvar] = Regressors.normalEquationAsym(xVar',tauMotor');

%% Convert theta vector to model parameters (motor calibration) and save it to the calibration map

% Get the motor calibration or create a new one. The method returns a
% handle on the MotorTransFunc object.
calib = MotorTransFunc.GetMotorTransFunc(motorName,calibrationMap);

switch frictionOrKtau
    case 'friction'
        % Check that the model is symmetrical
        [KcP, KcN, KvP, KvN] = deal(thetaPosXvar(1),thetaNegXvar(1),thetaPosXvar(2),thetaNegXvar(2));
        if abs(KcP+KcN)>abs(KcP)/100 || abs(KvP-KvN)>abs(KvP)/100
            warning('calibrateSensors: The friction model is not symmetrical');
        end
        % Run a fitting again but matching a single Kc and a single Kv
        theta = Regressors.normalEquationSym(xVar',tauMotor');
        calib.setFriction(theta(1), theta(2));
        
    case 'ktau'
        % Check that the model is symmetrical
        [KoffP, KoffN, KpwmP, KpwmN] = deal(thetaPosXvar(1),thetaNegXvar(1),thetaPosXvar(2),thetaNegXvar(2));
        if ...
                abs(KoffP+KoffN)>abs(KoffP)/100 ...
                || abs(KpwmP-KpwmN)>abs(KpwmP)/100
            warning('calibrateSensors: The Ktau model is not symmetrical');
        end
        % Run a fitting again but matching a single Ktau
        theta = Regressors.normalEquationSym(xVar',tauMotor');
        if abs(theta(1))>1e-3 % Tau offset
            warning('calibrateSensors: There is a torque offset in the model PWM to torque !!');
        end
        % theta_2 = Tau(Nm)/PWM(%) => theta_2*100/fullscale =
        % Tau(Nm)/PWM(raw) = Kpwm Nm.raw^{-1}
        % \overline{Kpwm} = 1/Kpwm = (1/theta_2)*(fullscale/100)
        calib.setKpwm(theta(2)*100/jointMotorCoupling.fullscalePWMs(motorIdx));
        
    otherwise
        error('calibrateSensors: unknown calibration type !!');
end

% Plot fitted model over acquired data.
obj.plotModel(frictionOrKtau,theta,xVar,1000);

end
