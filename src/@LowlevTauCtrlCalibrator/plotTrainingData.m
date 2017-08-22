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

%% build input data for calibration
%
% build sensor data parser
dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jointMotorCoupling.coupledJoints);

plot = false; loadJointPos = true;


data = SensorsData(dataPath,'',obj.subSamplingSize,...
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
time = data.time;
tau  = data.parsedParams.taus_state;

switch frictionOrKtau
    case 'friction'
        dqMrad = data.parsedParams.dqMsRad_state;
        
        % filtered Tau(time) & dqM(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor velocity and torque over time','motorVel_N_TorqFilt',...
            time,dqMrad,time,tau,...
            'Motor velocity (radians/s)','Motor torque (N.m)');
        
        % filtered Tau VS dqM
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor velocity to torque model','motorVel2torq',...
            dqMrad,tau,...
            [],[],...
            'Motor velocity (radians/s)','Motor torque (N.m)',...
            'Training data','');
        
    case 'ktau'
        pwm = data.parsedParams.pwms_state;
        
        % filtered Tau(time) & pwm(time)
        Plotter.plot2funcTimeseriesYY(...
            figuresHandler,...
            'Motor PWM and torque over time','motorPWM_N_torqFilt',...
            time,pwm,time,tau,...
            'Motor PWM (duty cycle)','Motor torque (N.m)');
        
        % filtered Tau VS pwm
        Plotter.plot2dDataNfittedModel(...
            figuresHandler,...
            'Motor PWM to torque model','motorPWM2torq',...
            pwm,tau,...
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

