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
        dqMrad = data.parsedParams.(['dqMsRad_' jointMotorCoupling.part '_state'])(motorIdx,:);
        
        % filtered Tau(time) & dqM(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor velocity and torque over time','motorVel_N_TorqFilt',...
            time,dqMrad,time,tauMotor,...
            'Motor velocity (radians/s)','Motor torque (N.m)');
        
        % filtered Tau VS dqM
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor velocity to torque model','motorVel2torq',...
            dqMrad,tauMotor,...
            [],[],...
            'Motor velocity (radians/s)','Motor torque (N.m)',...
            'Training data','');
        
    case 'ktau'
        pwm = data.parsedParams.(['pwms_' jointMotorCoupling.part '_state'])(motorIdx,:);
        
        % filtered Tau(time) & pwm(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor PWM and torque over time','motorPWM_N_torqFilt',...
            time,pwm,time,tauMotor,...
            'Motor PWM (duty cycle)','Motor torque (N.m)');
        
        % filtered Tau VS pwm
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor PWM to torque model','motorPWM2torq',...
            pwm,tauMotor,...
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

