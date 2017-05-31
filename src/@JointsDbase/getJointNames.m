function jointNameList = getJointNames( obj,part )
%getJointNames Get joints names from a given part

% build query (input properties to match)
inputProp.format = 1;
inputProp.data = {'part',part};

% query data
jointNameListDbase = obj.getPropList(inputProp,'jointName');

%% WORKAROUND begin:
% the joints list 'jointNameList' should be orederd as in the app GUI and
% YARP indexes, so we force that order here.
% 
% Fine selection of joint encoders:
% Select the joints to calibrate through the respective indexes. These indexes match 
% the joint names listed below, as per the joint naming convention described in 
% 'http://wiki.icub.org/wiki/ICub_Model_naming_conventions', except for the torso.
%
%      shoulder pitch roll yaw   |   elbow   |   wrist prosup pitch yaw   |  
% arm:          0     1    2     |   3       |         4      5     6     |
%
%      hip      pitch roll yaw   |   knee    |   ankle pitch  roll       |  
% leg:          0     1    2     |   3       |         4      5          |
%
%               yaw   roll pitch |
% torso:        0     1    2     |
%
%               pitch roll yaw   |
% head:         0     1    2     |
%

% static defintion of the joint names
persistent jointsListFromPart;

% macros for repetitive names and codes between left and right parts
armJoints = @(side) {...
    [side '_shoulder_pitch'],[side '_shoulder_roll'],[side '_shoulder_yaw'],...
    [side '_elbow'],[side '_wrist_prosup'],[side '_wrist_pitch'],[side '_wrist_yaw']};

legJoints = @(side) {...
    [side '_hip_pitch'],[side '_hip_roll'],[side '_hip_yaw'], ...
    [side '_knee'],...
    [side '_ankle_pitch'],[side '_ankle_roll']};

% Parts list
parts = {'left_arm','right_arm','left_leg','right_leg','torso','head'};

% desired ordered joints list
jointsLists = {...
    armJoints('l'),armJoints('r'),...
    legJoints('l'),legJoints('r'),...
    {'torso_yaw','torso_roll','torso_pitch'},...
    {'neck_pitch', 'neck_roll', 'neck_yaw'}};

% Build map table
jointsListFromPart = containers.Map(parts,jointsLists);

% query data
refJointNameList = jointsListFromPart(part);
jointNameListReorderedBitmap = ismember(refJointNameList,jointNameListDbase);
reordJointNameList = refJointNameList(jointNameListReorderedBitmap);
%% WORKAROUND end.

jointNameList = reordJointNameList(:)';

end
