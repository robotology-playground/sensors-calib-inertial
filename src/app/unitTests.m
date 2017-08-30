% Add main folders in Matlab path
run generatePaths.m;

%% clear all variables and close all previous figures
run unitTestsInit;

%% test retrieval of kinematic_mj and axis list directly using YARP bindings

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

%% Test same features using the class RemoteControlBoard

run unitTestsInit;

remoteCtrlBoard = RemoteControlBoard('icubSim','left_arm');
rawCouplingInfo = remoteCtrlBoard.getRawCoupling();
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


%% Below tests require a full RobotModel class object.
% 
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

jmCouplings = model.jointsDbase.getJMcouplings('joints',jointNameList)

% Get part name from joint/motor group label
parts = model.jointsDbase.getPartFromJMcouplings(jmCouplings)

% Get the joint index as mapped in the motors control board server.
[jointIdxes] = model.jointsDbase.getJointIdxesFromCtrlBoard(jointNameList)


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
vecModes.fromMatlab([y.VOCAB_CM_IDLE y.VOCAB_CM_PWM y.VOCAB_CM_TORQUE])
iCtrlMode.setControlModes(3,vecJoints,vecModes)
iCtrlMode.getControlModes(3,vecJoints,vecModes)

%% Test getJointsMappedIdxes(), setJointsControlMode() and setMotorsPWM()
jointsIdxes = obj.getJointsMappedIdxes({'l_knee'})
obj.setJointsControlMode(jointsIdxes,'pwmctrl')
obj.setMotorsPWM(jointsIdxes,[0])

% Set each motor back to position control mode
obj.setJointsControlMode(jointsIdxes,'ctrl')

