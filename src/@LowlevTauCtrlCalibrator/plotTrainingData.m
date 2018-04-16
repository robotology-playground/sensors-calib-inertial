function plotTrainingData(obj,...
    dataPath,measedSensorList,measedPartsList,...
    model,taskSpecificParams)

% This function plots the acquired data for the friction or ktau calibration
%   Detailed explanation goes here

% Get calibration map
calibrationMap = model.calibrationMap;

% Unwrap task specific parameters, defines:
% - frictionOrKtau       -> = 'friction' for friction calibration
%                           = 'ktau' for ktau calibration
% - jointMotorCoupling   -> label for retrieving the currently calibrated
%                           joint/motor group info. Refer to jointsDbase
%                           class interface.
% - savePlot
% 
% - exportPlot
% 
% a joint/motor group info is formatted as follows:
% group.coupledJoints : ordered list of joint names (size 1 or n)
% group.coupledMotors : ordered list of MotorFriction object handles (same size)
% group.T             : 3x3 matrix or integer 1
% 
Init.unWrap(taskSpecificParams);

% Get the coupling info from the motor name. Each motor belongs to a single coupling set.
jointMotorCoupling = cell(model.jointsDbase.getJMcouplings('motors',{motorName})){1};

%% build input data for calibration
%
% build sensor data parser
dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jointMotorCoupling.coupledJoints);

plot = false; loadJointPos = true;

data = SensorsData(dataPath,obj.subSamplingSize,...
    obj.timeStart,obj.timeStop,plot,...
    calibrationMap,obj.filtParams);
data.buildInputDataSet(loadJointPos,dataLoadingParams);

%============================================================
% Plot the data in order to control the measurements quality
% 

% define data folder
plotFolder = [dataPath '/diag'];

% Create figures handler
figuresHandler = DiagPlotFiguresHandler(plotFolder);
obj.figuresHandlerMap(obj.task) = figuresHandler;

% Joint encoder velocities and torques, and motor PWM measurements can be
% retrieved from the 'data' structure:
% 
% For N samples of dimension D (group of D coupled joints), we get:
% 
% Motor velocities table [DxN] : data.parsedParams.dqMsRad_<label>
% joint PWM table [DxN]        : data.parsedParams.pwms_<label>
% joint torques table [DxN]    : data.parsedParams.taus_<label>
% 
% Parameter names finishing by 's' are the ones recomputed after resampling
% (refer to 'subSamplingSize' in lowLevTauCtrlCalibratorDevConfig.m config
% file).
% 
time = data.parsedParams.time;

% Get the calibrated joint index as mapped in the motors control board server.
% jointIdxes = model.jointsDbase.getAxesIdxesFromCtrlBoard('joints',jointMotorCoupling.coupledJoints);
[~,motorIdx] = ismember(motorName,jointMotorCoupling.coupledMotors);

% Get respective torques (matrix 6xNsamples)
tauJoints  = data.parsedParams.(['taus_' jointMotorCoupling.part '_state']);

% FRICTION parameters
%
% We express the joint velocities and torques w.r.t. the motor respective
% quantities using the coupling matrix Tm2j (motor to joint) and gearbox ratios:
% 
% dq_j = Tm2j * Gm2j * dq_m
%
% Where Gm2j is a diagonal matrix. We then pose the conservation of
% transmission power:
%
% dq_j' * Tau_j = dq_m' * Tau_m
%
% <=> dq_m' * Gm2j' * Tm2j' * Tau_j = dq_m' * Tau_m  ∀dq_m
%
% <=> Tau_m = Gm2j' * Tm2j' * Tau_j
% 
% Anyway we consider here the motor and gearbox as a single block, and
% the velocity and torque as the outputs of that same block:
%
% xVar = S * Gm2j * dq_m
% yVar = S * Tm2j' * Tau_j
%
% Where Gm2j is a diagonal matrix whose diagonal terms are represented by
% gearboxDqM2Jratios, and S is a selective matrix. So, for motorIdx "i",
% S=[0..0 1 0..0] (ith column set to 1). For any matrix A, we get S * A =
% A(i,:), and A * S' = A(:,i). We get or each sample at instant "t":
%
% xVar = Gm2j(i,:) * dq_m = gearboxDqM2Jratios(i) * dq_m(i)
% yVar = (Tm2j * S')' * Tau_j = Tm2j(:,i)' * Tau_j
%
tauMotorG = jointMotorCoupling.Tm2j(:,motorIdx)' * tauJoints;

switch frictionOrKtau
    case 'friction'
        dqMradG = ...
            jointMotorCoupling.gearboxDqM2Jratios{motorIdx} ...
            * data.parsedParams.(['dqMsRad_' jointMotorCoupling.part '_state'])(motorIdx,:);
        
        % filtered Tau(time) & dqM(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor velocity and torque over time','motorVel_N_TorqFilt',...
            time,dqMradG,time,tauMotorG,...
            'Motor velocity (radians/s)','Motor torque (N.m)');
        
        % filtered Tau VS dqM
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor velocity to torque model','motorVel2torq',...
            dqMradG,tauMotorG,...
            [],[],...
            'Motor velocity (radians/s)','Motor torque (N.m)',...
            'Training data','');
        
    case 'ktau'
        pwmDutyCycle = ...
            data.parsedParams.(['pwms_' jointMotorCoupling.part '_state'])(motorIdx,:) ...
            * jointMotorCoupling.fullscalePWMs{motorIdx}/100;
        
        % filtered Tau(time) & pwm(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor PWM and torque over time','motorPWM_N_torqFilt',...
            time,pwmDutyCycle,time,tauMotorG,...
            'Motor PWM (duty cycle)','Motor torque (N.m)');
        
        % filtered Tau VS pwm
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor PWM to torque model','motorPWM2torq',...
            pwmDutyCycle,tauMotorG,...
            [],[],...
            'Motor PWM (duty cycle)','Motor torque (N.m)',...
            'Training data','');
        
    otherwise
        error('plotTrainingData: unknown calibration type !!');
end

% Define callback for saving the plots into matlab figure files and
% eventually export them to PNG files.
obj.savePlotCallback = @() obj.savePlot(figuresHandler,savePlot,exportPlot,dataPath);

end

