%
% Model parameters for the low level joint torque control calibration
% 

% libraries
import containers.Map;

% left arm parameters
axisConfig = {...
    'l_shoulder_pitch' 'l_shoulder_roll' 'l_shoulder_yaw' 'l_elbow'   % AxisName
    'l_shoulder_1'     'l_shoulder_2'    'l_shoulder_3'   'l_elbow'   % MotorName
    32000               32000            32000            32000       % fullscalePWM
    100.00              100.00           100.00           100.00   }; % Gearbox_M2J

left_arm.jointNames   = axisConfig(1,:);
left_arm.motorNames   = axisConfig(2,:);
left_arm.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
left_arm.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
left_arm.matrixM2J = {...
   [1.000   0.000   0.000   0.000
    1.000   0.615   0.000   0.000
    0.000  -0.615   0.615   0.000
    0.000   0.000   0.000   1.000]};

% right arm parameters
axisConfig = {...
    'r_shoulder_pitch' 'r_shoulder_roll' 'r_shoulder_yaw' 'r_elbow'   % AxisName
    'r_shoulder_1'     'r_shoulder_2'    'r_shoulder_3'   'r_elbow'   % MotorName
    32000              32000             32000            32000       % fullscalePWM
    -100.00            -100.00           -100.00          -100.00  }; % Gearbox_M2J

right_arm.jointNames   = axisConfig(1,:);
right_arm.motorNames   = axisConfig(2,:);
right_arm.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
right_arm.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
right_arm.matrixM2J = {...
   [1.000   0.000   0.000   0.000
    1.000   0.615   0.000   0.000
    0.000  -0.615   0.615   0.000
    0.000   0.000   0.000   1.000]};

% left leg parameters
axisConfig = {...
    'l_hip_pitch'  'l_hip_roll'  'l_hip_yaw'  'l_knee'  'l_ankle_pitch'  'l_ankle_roll'   % AxisName
    'l_hip_pitch'  'l_hip_roll'  'l_hip_yaw'  'l_knee'  'l_ankle_pitch'  'l_ankle_roll'   % MotorName
    32000          32000         32000        32000     32000            32000            % fullscalePWM
    -100.0         100.0         -100.0       -100.0    100.0            100.0         }; % Gearbox_M2J

left_leg.jointNames   = axisConfig(1,:);
left_leg.motorNames   = axisConfig(2,:);
left_leg.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
left_leg.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
left_leg.matrixM2J = {...
   [1.00    0.00    0.00    0.00
    0.00    1.00    0.00    0.00
    0.00    0.00    1.00    0.00
    0.00    0.00    0.00    1.00],...
   [1.00    0.00
    0.00    1.00]};

% right leg parameters
axisConfig = {...
    'r_hip_pitch'  'r_hip_roll'  'r_hip_yaw'  'r_knee'  'r_ankle_pitch'  'r_ankle_roll'   % AxisName
    'r_hip_pitch'  'r_hip_roll'  'r_hip_yaw'  'r_knee'  'r_ankle_pitch'  'r_ankle_roll'   % MotorName
    32000          32000         32000        32000     32000            32000            % fullscalePWM
    100.0         -100.0         100.0        100.0     -100.0           -100.0        }; % Gearbox_M2J

right_leg.jointNames   = axisConfig(1,:);
right_leg.motorNames   = axisConfig(2,:);
right_leg.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
right_leg.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
right_leg.matrixM2J = {...
   [1.00    0.00    0.00    0.00
    0.00    1.00    0.00    0.00
    0.00    0.00    1.00    0.00
    0.00    0.00    0.00    1.00],...
   [1.00    0.00
    0.00    1.00]};

% torso parameters
axisConfig = {...
    'torso_yaw' 'torso_roll' 'torso_pitch'   % AxisName
    'torso_1'   'torso_2'    'torso_3'       % MotorName
    32000       32000        32000           % fullscalePWM
    -100.00     -100.00      -100.00      }; % Gearbox_M2J

torso.jointNames   = axisConfig(1,:);
torso.motorNames   = axisConfig(2,:);
torso.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
torso.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
torso.matrixM2J = {...
   [0.500    0.500    0.000
   -0.500    0.500    0.000
    0.275    0.275    0.550]};

% head parameters
axisConfig = {...
    'neck_pitch' 'neck_roll' 'neck_yaw' 'eyes_tilt' 'eyes_vers' 'eyes_verg'   % AxisName
    'neck_1'     'neck_2'    'neck_yaw' 'eyes_tilt' 'eyes_vers' 'eyes_verg'   % MotorName
    3360         3360        3360        3360        3360        3360         % fullscalePWM
    161.68       161.68      100         -141        50          50        }; % Gearbox_M2J

head.jointNames   = axisConfig(1,:);
head.motorNames   = axisConfig(2,:);
head.fullscalePWM = Map(axisConfig(2,:),axisConfig(3,:));
head.Gearbox_M2J  = Map(axisConfig(2,:),axisConfig(4,:));
head.matrixM2J = {...
   [0.500  -0.500
    0.500   0.500],...
   [1.000   0.000   0.000   0.000
    0.000   1.000   0.000   0.000
    0.000   0.000   0.500   0.500
    0.000   0.000  -0.500   0.500]};

