% Set the Simulink model blocks main common parameters
% robotName, localName, Ts and ROBOT_DOF. ROBOT_DOF is parsed from the
% configuration file yarpWholeBodyInterface.ini defined for the current
% model.

robotName='icub';
localName='simulink';
ROBOT_DOF=20;
Ts=0.01;

qErr = 1*pi/180; % radians
dqErr = 0.5*pi/180; % radians/s

qjDes = zeros(ROBOT_DOF,1);
dqiRef = 10*pi/180; % absolute value in radians/s

refMask = zeros(ROBOT_DOF,1);
refMask(1:4) = 1;   %left_arm
refMask(5:8) = 1;   %right_arm
refMask(9:14) = 1;  %left_leg
refMask(15:20) = 1; %right_leg

% refMask(1:4) = [-50 50 -50 50]'; %left_arm
% refMask(5:8) = [-50 50 -50 50]'; %right_arm
% refMask(9:14) = 50; %left_leg
% refMask(15:20) = 50; %right_leg
% refMask([13 14 19 20])=10;

% Parse the ROBOT_DOF

% check WBI ordering in 
% https://github.com/robotology-playground/WBI-Toolbox/wiki/Details-on-iCub-joints-ordering-in-WBI-Toolbox

%   Joints: 
%     [0] r_hip_pitch (dofs: 1) : root_link<-->r_hip_1
%     [1] r_hip_roll (dofs: 1) : r_hip_1<-->r_hip_2
%     [2] r_hip_yaw (dofs: 1) : r_hip_3<-->r_upper_leg
%     [3] r_knee (dofs: 1) : r_upper_leg<-->r_lower_leg
%     [4] r_ankle_pitch (dofs: 1) : r_lower_leg<-->r_ankle_1
%     [5] r_ankle_roll (dofs: 1) : r_ankle_1<-->r_ankle_2
%     [6] l_hip_pitch (dofs: 1) : root_link<-->l_hip_1
%     [7] l_hip_roll (dofs: 1) : l_hip_1<-->l_hip_2
%     [8] l_hip_yaw (dofs: 1) : l_hip_3<-->l_upper_leg
%     [9] l_knee (dofs: 1) : l_upper_leg<-->l_lower_leg
%     [10] l_ankle_pitch (dofs: 1) : l_lower_leg<-->l_ankle_1
%     [11] l_ankle_roll (dofs: 1) : l_ankle_1<-->l_ankle_2
%     [12] torso_pitch (dofs: 1) : root_link<-->torso_1
%     [13] torso_roll (dofs: 1) : torso_1<-->torso_2
%     [14] torso_yaw (dofs: 1) : torso_2<-->chest
%     [15] r_shoulder_pitch (dofs: 1) : chest<-->r_shoulder_1
%     [16] r_shoulder_roll (dofs: 1) : r_shoulder_1<-->r_shoulder_2
%     [17] r_shoulder_yaw (dofs: 1) : r_shoulder_2<-->r_shoulder_3
%     [18] r_elbow (dofs: 1) : r_upper_arm<-->r_elbow_1
%     [19] l_shoulder_pitch (dofs: 1) : chest<-->l_shoulder_1
%     [20] l_shoulder_roll (dofs: 1) : l_shoulder_1<-->l_shoulder_2
%     [21] l_shoulder_yaw (dofs: 1) : l_shoulder_2<-->l_shoulder_3
%     [22] l_elbow (dofs: 1) : l_upper_arm<-->l_elbow_1
%     [23] neck_pitch (dofs: 1) : chest<-->neck_1
%     [24] neck_roll (dofs: 1) : neck_1<-->neck_2
%     [25] neck_yaw (dofs: 1) : neck_2<-->head
%     [26] r_leg_ft_sensor (dofs: 0) : r_hip_2<-->r_hip_3
%     [27] r_foot_ft_sensor (dofs: 0) : r_ankle_2<-->r_foot
%     [28] l_leg_ft_sensor (dofs: 0) : l_hip_2<-->l_hip_3
%     [29] l_foot_ft_sensor (dofs: 0) : l_ankle_2<-->l_foot
%     [30] r_arm_ft_sensor (dofs: 0) : r_shoulder_3<-->r_upper_arm
%     [31] l_arm_ft_sensor (dofs: 0) : l_shoulder_3<-->l_upper_arm
