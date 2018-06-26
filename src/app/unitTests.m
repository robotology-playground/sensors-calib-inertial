% Add main folders in Matlab path
run generatePaths.m;

%% 1 - test retrieval of kinematic_mj and axis list directly using YARP bindings

run unitTestsInit; % clear all variables and close all previous figures

% Set robot environment names from the model name (yarp port prefix, yarp
% robot name)
robotEnvNames = RobotModel.getRobotEnvNames(init.modelName);

% open remote control board and get list of remote debug variables
obj.options = yarp.Property('(device remote_controlboard)');
obj.options.put('remote',['/' robotEnvNames.yarpPortPrefix '/torso']);
obj.options.put('local','/collector/torso');
obj.driver = yarp.PolyDriver()
obj.driver.open(obj.options)
ivar = obj.driver.viewIRemoteVariables()
varList = yarp.Bottle();
ivar.getRemoteVariablesList(varList);
varList.toString()

% get coupling parameters
kinematic_mjVar=yarp.Bottle();
ivar.getRemoteVariable('kinematic_mj',kinematic_mjVar);
kinematic_mjVar.toString()

% convert them to a matrix
kinematic_mjMatStr = kinematic_mjVar.get(0);
str2num(kinematic_mjMatStr.toString)

% get axis list
ipos = obj.driver.viewIPositionControl();
nbAxes = ipos.getAxes();

iaxis = obj.driver.viewIAxisInfo();
axisNames = cell(1,nbAxes);
for axisIdx = 1:nbAxes
    axisNames{1,axisIdx} = iaxis.getAxisName(axisIdx-1);
end

%% 2 - Test same features using the class RemoteControlBoard

run unitTestsInit;

% Set robot environment names from the model name (yarp port prefix, yarp
% robot name)
robotEnvNames = RobotModel.getRobotEnvNames(init.modelName);

remoteCtrlBoard = RemoteControlBoard(robotEnvNames.yarpPortPrefix,'left_arm');
%rawCouplingInfo = remoteCtrlBoard.getRawCoupling();
nbAxes = remoteCtrlBoard.getAxes();
axesNames = remoteCtrlBoard.getAxesNames();
jointIdx = remoteCtrlBoard.getJointsMappedIdxes({'l_shoulder_pitch','l_shoulder_yaw','l_elbow','l_wrist_yaw'});
couplingList = remoteCtrlBoard.getCouplings();
delete(remoteCtrlBoard);

for part = {'head','torso','left_arm','right_arm','left_leg','right_leg'}
    remoteCtrlBoard = RemoteControlBoard(robotEnvNames.yarpPortPrefix,cell2mat(part));
    couplingList = remoteCtrlBoard.getCouplings();
    for coupling = couplingList
        coupling{1}
        coupling{1}.Tm2j
    end
    delete(remoteCtrlBoard);
    clear remoteCtrlBoard;
end


%% 3 - Below tests require a full RobotModel class object.
% 
run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.modelName,init.modelPath,init.calibrationMapFile);

% Get the list of joint/motor couplings
jointNameList = {...
    'l_shoulder_pitch','l_elbow','l_wrist_yaw',...
    'torso_pitch','torso_roll','torso_yaw',...
    'neck_roll',...
    'l_ankle_roll'};

motorNameList = {...
    'l_shoulder_m1','l_elbow_m','l_wrist_yaw_m',...
    'torso_m3','torso_m2','torso_m1',...
    'neck_m2',...
    'l_ankle_roll_m'};

% Get the list of joint/motor couplings.
jmCouplings = model.jointsDbase.getJMcouplings('joints',jointNameList)

% Get part name and motor names list from joint/motor coupling
parts = JointMotorCoupling.getPartsFromList(jmCouplings)
motorNameListExpdd = JointMotorCoupling.getMotorsFromList(jmCouplings)

% Get part names holding the motors
parts = model.jointsDbase.getPartFromMotors(motorNameList)

% Get the joints indexes as mapped in the motors control board server.
jointIdxes = model.jointsDbase.getAxesIdxesFromCtrlBoard('joints',jointNameList)

% Get the motors indexes as mapped in the motors control board server.
motorIdxes = model.jointsDbase.getAxesIdxesFromCtrlBoard('motors',motorNameList)

% Get joints sharing the same indexes as the given motors
jointNameListSharingIdx = model.jointsDbase.getCpldJointSharingIdx(motorNameList)

% Get motors sharing the same indexes as the given joints
motorNameList2 = model.jointsDbase.getCpldMotorSharingIdx(jointNameList)

% Get the gearbox ratios and fullscale values for a given list of motors
[gearboxDqM2Jratio,fullscalePWM] = model.jointsDbase.getMotorGearboxRatioNfullscale(motorNameList)

%% 4 - Below tests require a full RobotModel class object.
% 
run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.modelName,init.modelPath,init.calibrationMapFile);

obj=RemoteControlBoardRemapper(model,'test')

%% Test the IControlMode2 class methods and the yarp bindings

obj.open({'left_leg'})
iCtrlMode = obj.driver.viewIControlMode2()

iCtrlMode.getControlMode(2)
vecModes=yarp.IVector(3)
vecJoints=yarp.IVector(3)
vecModes.zero()
vecJoints.fromMatlab([1 2 3])
iCtrlMode.setControlMode(2,y.VOCAB_CM_PWM)
iCtrlMode.getControlModes(3,vecJoints,vecModes)
% check modes
RemoteControlBoardRemapper.vocab2ctrlMode.values(num2cell(vecModes.toMatlab))
% set modes and check
vecModes.fromMatlab([y.VOCAB_CM_IDLE y.VOCAB_CM_PWM y.VOCAB_CM_TORQUE])
iCtrlMode.setControlModes(3,vecJoints,vecModes)
iCtrlMode.getControlModes(3,vecJoints,vecModes)
RemoteControlBoardRemapper.vocab2ctrlMode.values(num2cell(vecModes.toMatlab))
% restore previous modes
vecModes.fromMatlab([y.VOCAB_CM_POSITION y.VOCAB_CM_POSITION y.VOCAB_CM_POSITION])
iCtrlMode.setControlModes(3,vecJoints,vecModes)
iCtrlMode.getControlModes(3,vecJoints,vecModes)
RemoteControlBoardRemapper.vocab2ctrlMode.values(num2cell(vecModes.toMatlab))

obj.close();

%% Test RemoteControlBoardRemapper public methods
% getAxes(),
% getJointsNames(),
% getMotorsNames(),
% getJointsMappedIdxes(),
% setJointsControlMode(),
% getJointsControlMode(),
% setMotorPWMcontrolMode(),
% setMotorsPWM(),
% setMotorPWM(),
% getMotorsPWM()
% getMotorEncoders(),
% getMotorEncoderSpeeds(),
% getJointTorques().
obj.open({'torso'})

obj.getJointsNames(1:obj.getAxes())
obj.getMotorsNames(1:obj.getAxes())

jointsIdxes = obj.getJointsMappedIdxes({'torso_yaw','torso_roll','torso_pitch'})
% change control mode to PWM
[ok,modes] = obj.getJointsControlMode(jointsIdxes)
ok = obj.setJointsControlMode(jointsIdxes,'pwmctrl')
[ok,modes] = obj.getJointsControlMode(jointsIdxes)
pause
% change PWM
pwmVecMat = obj.getMotorsPWM(jointsIdxes)
ok = obj.setMotorsPWM(jointsIdxes,[0 0 0])
pwmVecMat = obj.getMotorsPWM(jointsIdxes)

% get motor positions and velocities
[readEncs,timeEncs] = obj.getMotorEncoders(jointsIdxes)
[readSpeeds] = obj.getMotorEncoderSpeeds(jointsIdxes)

% get joint torques
[torqVecMat] = obj.getJointTorques(jointsIdxes)

% Set each motor back to position control mode
ok = obj.setJointsControlMode(jointsIdxes,'ctrl')
[ok,modes] = obj.getJointsControlMode(jointsIdxes)
obj.close();


%% 5 - Timers and rate threads.
% 

% clear all variables and close all previous figures
clear
close all
clc

%Clear static data
clear classes;

% Clear all timers
System.clearTimers();

% Create YARP Network device, for initializing YARP classes for communication
yarp.Network.init();

% Display text window
timerDisplay = sprintf([...
    'ellapsed Yarp time = 0.000000 \n'...
    'Error w.r.t. local time = 0.000000 \n'...
    'Error w.r.t. Yarp time = 0.000000']);
out = dialog(...
    'WindowStyle','normal','units','normalized',...
    'Position',[0.3,0.4,0.4,0.25],'resize','off',...
    'Name','Timer stats');
aTimerStatsH=uicontrol(...
    'parent',out,'Style','text','String',timerDisplay,...
    'units','normalized','fontunits','normalized',...
    'fontsize',0.15,'Position',[0.1,0.1,0.8,0.8]);

% define the rate function
rateThreadPeriod = 0.01;
testFunction = @(timerObj,thisEvent,threadStopFcn) UT.testRateFunction(timerObj,thisEvent,threadStopFcn,rateThreadPeriod,aTimerStatsH);

% define the rate threads
%
% local timer
myRateThread=RateThread(testFunction,@(a,b) disp('start'),@(a,b) disp('stop'),'local',rateThreadPeriod,20);
ok = myRateThread.run(true)
pause;
ok = myRateThread.run(false)
pause;
myRateThread.stop(true)
delete(myRateThread)

% local timer synced with Yarp
% myRateThread=RateThread(testFunction,@(a,b) disp('start'),@(a,b) disp('stop'),'localSyncYarp',rateThreadPeriod,20);
% myRateThread.run(false);
% myRateThread.stop(true);
% delete(myRateThread);

% Yarp timer only
myRateThread=RateThread(testFunction,@(a,b) disp('start'),@(a,b) disp('stop'),'yarp',rateThreadPeriod,20);
ok = myRateThread.run(true)
pause;
isit = myRateThread.isRunning()
ok = myRateThread.run(false)
isit = myRateThread.isRunning()
pause;
myRateThread.stop(true)
delete(myRateThread)

System.clearTimers;
clear Timers;


%% 6 - High-level position control emulation.
% 
run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.modelName,init.modelPath,init.calibrationMapFile);

% Create motor control boards remapper
ctrlBoard = RemoteControlBoardRemapper(model,'test')

%% PID controller
ctrlBoard.open({'torso'})

% PID gains
jointsIdxes = ctrlBoard.getJointsMappedIdxes({'torso_yaw','torso_roll','torso_pitch'})
[readPids,readPidsMatArray] = ctrlBoard.getMotorsPids('posPID',jointsIdxes);

% close device
ctrlBoard.close()

% PID controller
aFilter = DSP.IdentityFilter([])         % define the filter
PIDCtrller = DSP.PIDcontroller(...
    [readPidsMatArray.Kp],[readPidsMatArray.Kd],[readPidsMatArray.Ki],...                 % P, I, D gains
    [readPidsMatArray.max_int],[readPidsMatArray.max_output],[readPidsMatArray.scale],... % max integral term and max correction term
    aFilter)                                                                              % discrete PID controller

PIDCtrller.reset([1,1,1]')

[intSat,outSat,nextCorr] = PIDCtrller.step(0.01,[0.017,0.017,0.017]',[0,0,0]',[0,0,0]')

%% PWM controller

% Set the motor in PWM control mode and handle the coupled
% motors keeping their control mode and state unchanged. If
% this is not supported by the YARP remoteControlBoardRemapper,
% emulate it. We can only emulate position control.
% For this create an PWM controller that handles single and
% coupled motors seamlessly.

%% Set a non-coupled motor to PWM control mode and PWM value using motor name
ctrlBoard.open({'right_leg'})
pwmController = MotorPWMcontroller('r_knee_m',ctrlBoard,System.Const.ThreadON);

% Set the desired PWM level (0-100%) for the named motor
pwmController.setMotorPWM(0)
pause

% Stop the controller. This also restores the previous
% control mode for the named motor and eventual coupled
% motors.
pwmController.stop();
clear pwmController
ctrlBoard.close()
System.clearTimers; % cleanup timers

%% Set a coupled motor to PWM control mode and PWM value
% In runPwmEmulPosCtrlMode(), replace "obj.ctrllerThread = RateThread(...)"
% by "obj.ctrllerThread = UT.RateThread_CB(...)"
ctrlBoard.open({'torso'})
% change control mode to Position control
ok = ctrlBoard.setJointsControlMode(1:3,'ctrl')
[ok,modes] = ctrlBoard.getJointsControlMode(1:3)

pwmController = MotorPWMcontroller('torso_m1',ctrlBoard,System.Const.ThreadTEST)
f = pwmController.ctrllerThread.threadTimer.TimerFcn;
aThreadTimer = pwmController.ctrllerThread.threadTimer;
pause
pwmController.setMotorPWM(3)
f(aThreadTimer,[]);
yarp.delay(5);
pwmController.setMotorPWM(-3)
f(aThreadTimer,[]);
yarp.delay(5);
pwmController.stop();
pause
pwmController.setMotorPWM(3); % this shouldn't work
clear pwmController
ctrlBoard.close();
System.clearTimers; % cleanup timers

%% Set a coupled motor to PWM control mode and PWM value
% In runPwmEmulPosCtrlMode(), restore "obj.ctrllerThread = RateThread(...)"
ctrlBoard.open({'torso'})
% change control mode to Position control
ok = ctrlBoard.setJointsControlMode(1:3,'ctrl')
[ok,modes] = ctrlBoard.getJointsControlMode(1:3)

pwmController = MotorPWMcontroller('torso_m1',ctrlBoard,System.Const.ThreadON)

% Set the desired PWM level (0-100%) for the named motor
pwmController.setMotorPWM(0)
pause
pwmController.setMotorPWM(2)
pause
pwmController.setMotorPWM(-2)
pause

% Stop the controller. This also restores the previous
% control mode for the named motor and eventual coupled
% motors.
pwmController.stop();
clear pwmController
ctrlBoard.close();
System.clearTimers; % cleanup timers

%% Set a coupled motor to PWM control mode and PWM value
ctrlBoard.open({'torso'})
% change control mode to Position control
ok = ctrlBoard.setJointsControlMode(1:3,'ctrl')
[ok,modes] = ctrlBoard.getJointsControlMode(1:3)

pwmController = MotorPWMcontroller('torso_m2',ctrlBoard,System.Const.ThreadON)

% Set the desired PWM level (0-100%) for the named motor
pwmController.setMotorPWM(0)
pause
pwmController.setMotorPWM(2)
pause
pwmController.setMotorPWM(-2)
pause

% Stop the controller. This also restores the previous
% control mode for the named motor and eventual coupled
% motors.
pwmController.stop();
clear pwmController
ctrlBoard.close();
System.clearTimers; % cleanup timers

% pwmCtrller = MotorPWMcontroller('l_shoulder_1',ctrlBoard,System.Const.ThreadON)
% 
% jointsIdxes = obj.getJointsMappedIdxes({'l_hip_roll'})
% ok = obj.setJointsControlMode(jointsIdxes,'pwmctrl')
% [ok,modes] = obj.getJointsControlMode(jointsIdxes)
% 
% % high-level control, keep joint at current position
% ok = obj.setMotorsPWM(jointsIdxes,[0])
% pause;
% 
% % Run a PID on the joint. Send a command every 10ms
% quit = false;
% while (~quit)
%     
% end
% 
% % End of test: set each motor back to position control mode
% ok = obj.setJointsControlMode(jointsIdxes,'ctrl')
% [ok,modes] = obj.getJointsControlMode(jointsIdxes)
% obj.close();
% clear all;


%% 7 - Test plotters from 'Plotter' class

run unitTestsInit;

figuresHandler = [];
time = 1:1000;
w = 2*pi/time(end)*2;
y1 = sin(w*time);
N = 0.2*(rand([1,1000])-0.5);
y1WithNoise = y1 + N;
y2 = cos(w*time)./10;
dy1 = w*cos(w*time);
dtFrac = 0.5;

Plotter.plotFuncTimeseries(...
    figuresHandler,'plotFuncTimeseries','',...
    time,y1,...
    'yLabel');

Plotter.plot2funcTimeseries(...
    figuresHandler,'plot2funcTimeseries','',...
    time,y1,y2,...
    'yLabel','y1Legend','y2Legend');

Plotter.plotFuncTimeseriesNderivative(...
    figuresHandler,'plotFuncTimeseriesNderivative','',...
    time,y1,dtFrac,dy1,...
    'yLabel','yLegend','dydtLegend');

Plotter.plot2funcTimeseriesYY(...
    figuresHandler,'plot2funcTimeseriesYY','',...
    time,y1,time,y2,...
    'yLabel1','yLabel2','y1Legend','y2Legend');

Plotter.plot2dDataNfittedModel(...
    figuresHandler,'plot2dDataNfittedModel','',...
    time,y1WithNoise,time,y1,...
    'xLabel','yLabel',...
    'dataLegend','modelLegend');


%% 8 - Realtime plotter

% clear all variables and close all previous figures
clear
close all
clc

%Clear static data
clear classes;

% Create YARP Network device, for initializing YARP classes for communication
yarp.Network.init();

% Figure parameters
figTitle = 'Motor velocity to torque model';
xLabel = 'Motor velocity (degrees/s)';
yLabel = 'Motor torque (N.m)';
% create figure
figH = figure('Name',figTitle);
% This is a temporary figure and won't be docked, so display it full screen.
set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
% title, axes labels, legend
title(figTitle,'Fontsize',16,'FontWeight','bold');
xlabel(xLabel,'Fontsize',12);
ylabel(yLabel,'Fontsize',12);
set(gca,'FontSize',12);
% figH.CurrentAxes.XLim = xRange;
% figH.CurrentAxes.YLim = yRange;
grid on;

% create animated line
h = animatedline;
axis([0 4*pi -1 1])
x = linspace(0,4*pi,100);
y = sin(x);
h.LineStyle = 'none';
h.Marker = 'o';
h.MarkerFaceColor = 'b';
h.Visible = 'on';
h.Selected = 'off';
h.UserData = [1,1]; % counters
colors = {'r','g','b','y','m'};

% define the thread and run
threadPeriod = 0.05;
threadTimeout = 60;
startFcn  = '';
stopFcn   = '';
updateFcn = @(~,~,~) UT.plotterThreadUpdateFcn(h,x,y,colors);

plotterThread = RateThread(...
    updateFcn,startFcn,stopFcn,'yarp',...
    threadPeriod,threadTimeout);

% run the new thread
ok = plotterThread.run(false); % run and don't wait for thread termination

pause;

plotterThread.stop(true);
clear plotterThread;
System.clearTimers; % cleanup timers

%% 9 - Test 'LowlevTauCtrlCalibrator'

run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.modelName,init.modelPath,init.calibrationMapFile);

% Load last acquired data accessors from file
if exist('lastAcqSensorDataAccessorMap.mat','file') == 2
    load('lastAcqSensorDataAccessorMap.mat','lastAcqSensorDataAccessorMap');
end
if ~exist('lastAcqSensorDataAccessorMap','var')
    lastAcqSensorDataAccessorMap = containers.Map('KeyType','char','ValueType','any');
end

% Just test the state transitions
task = UT.LowlevTauCtrlCalibrator_SM.instance();
task.run(init,model,lastAcqSensorDataAccessorMap);

% Test the state processings
task = UT.LowlevTauCtrlCalibrator_Proc.instance();
task.run(init,model,lastAcqSensorDataAccessorMap);

% Test the plotting and fitting functions
% - src/@LowlevTauCtrlCalibrator/plotTrainingData.m
% - src/@LowlevTauCtrlCalibrator/savePlot.m
% - src/@LowlevTauCtrlCalibrator/calibrateSensors.m
% - src/@LowlevTauCtrlCalibrator/plotModel.m
% - src/@MotorTransFunc/MotorTransFunc.m
% - src/@DiagPlotFiguresHandler/DiagPlotFiguresHandler.m (getFigure)
task = LowlevTauCtrlCalibrator.instance();
task.run(init,model,lastAcqSensorDataAccessorMap);


%% Uninitialize yarp
yarp.Network.fini();

