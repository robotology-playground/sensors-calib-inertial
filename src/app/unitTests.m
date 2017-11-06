% Add main folders in Matlab path
run generatePaths.m;


%% 1 - test retrieval of kinematic_mj and axis list directly using YARP bindings

run unitTestsInit; % clear all variables and close all previous figures

% open remote control board and get list of remote debug variables
obj.options = yarp.Property('(device remote_controlboard)');
obj.options.put('remote','/icubSim/torso');
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

remoteCtrlBoard = RemoteControlBoard('icubSim','left_arm');
%rawCouplingInfo = remoteCtrlBoard.getRawCoupling();
nbAxes = remoteCtrlBoard.getAxes();
axesNames = remoteCtrlBoard.getAxesNames();
jointIdx = remoteCtrlBoard.getJointsMappedIdxes({'l_shoulder_pitch','l_shoulder_yaw','l_elbow','l_wrist_yaw'});
couplingList = remoteCtrlBoard.getCouplings();
delete(remoteCtrlBoard);

for part = {'left_arm','right_arm','left_leg','right_leg','torso','head'}
    remoteCtrlBoard = RemoteControlBoard('icubSim',cell2mat(part));
    couplingList = remoteCtrlBoard.getCouplings();
    for coupling = couplingList
        coupling{1}
        coupling{1}.invT
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
model = RobotModel(init.robotName,init.modelPath,init.calibrationMapFile);

% Get the list of joint/motor couplings
jointNameList = {...
    'l_shoulder_pitch','l_elbow','l_wrist_yaw',...
    'torso_pitch','torso_roll','torso_yaw',...
    'neck_roll',...
    'l_ankle_roll'};

motorNameList = {...
    'm_left_arm_1','m_left_arm_4','m_left_arm_7',...
    'm_torso_3','m_torso_2','m_torso_1',...
    'm_head_2',...
    'm_left_leg_6'};

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


%% 4 - Below tests require a full RobotModel class object.
% 
run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.robotName,init.modelPath,init.calibrationMapFile);

%% Test the IControlMode2 class methods and the yarp bindings
obj=RemoteControlBoardRemapper(model,'test')
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
obj.close();

%% Test RemoteControlBoardRemapper public methods
% getJointsMappedIdxes(),
% setJointsControlMode(),
% getJointsControlMode(),
% setMotorPWMcontrolMode(),
% setMotorsPWM(),
% setMotorPWM(),
obj.open({'left_leg'})
jointsIdxes = obj.getJointsMappedIdxes({'l_knee'})
ok = obj.setJointsControlMode(jointsIdxes,'pwmctrl')
[ok,modes] = obj.getJointsControlMode(jointsIdxes)
ok = obj.setMotorsPWM(jointsIdxes,[0])

% Set each motor back to position control mode
ok = obj.setJointsControlMode(jointsIdxes,'ctrl')
[ok,modes] = obj.getJointsControlMode(jointsIdxes)
obj.close();

% Set a non-coupled motor to PWM control mode and PWM value using motor name
obj.open({'left_leg'})
[ok, coupling, couplingPrevMode] = obj.setMotorPWMcontrolMode('m_left_leg_4')
ok = obj.setMotorPWM('m_left_leg_4',0)
obj.close();

%% Set a coupled motor to PWM control mode and PWM value using motor name
obj.open({'torso'})
[ok, coupling, couplingPrevMode] = obj.setMotorPWMcontrolMode('m_torso_1')
ok = obj.setMotorPWM('m_torso_1',10)
ok = obj.setMotorPWM('m_torso_1',0)
obj.close();


%% 5 - Test 'LowlevTauCtrlCalibrator'

run unitTestsInit;

% Create robot model. The model holds the robot name, the parameters
% extracted from the URDF model, the sensor calibration parameters and the
% joint/motor parameters (PWM to torque rate, friction parameters, ...).
model = RobotModel(init.robotName,init.modelPath,init.calibrationMapFile);

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

% Test the 

%% Uninitialize yarp
yarp.Network.fini();

