% positionCtrlEmulatorTest.mdl model init parameters
% 

% Simulation timing
CONFIG.Tend = inf;
CONFIG.Ts = 0.01;

% Config block
% CONFIG.ctrledJoints = {'torso_yaw','torso_roll','torso_pitch'};
% CONFIG.ctrlBoards = {'torso'};
CONFIG.ctrledJoints = {'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw'};
CONFIG.ctrlBoards = {'right_arm'};

CONFIG.jointsDoF = length(CONFIG.ctrledJoints);

%% PID params

% left_leg
% CONFIG.pid.Kp = -2; % -1000
% CONFIG.pid.Kd =  0; %  0
% CONFIG.pid.Ki = -2; % -10000
% 
% CONFIG.pid.outLimit = 8;
% CONFIG.pid.IntLimit = 1.5;

% right_arm
CONFIG.pid.Kp = [-1 -1 -1]; % -1000
CONFIG.pid.Kd =  [0 0 0]; %  0
CONFIG.pid.Ki = [-1 -1 -1]; % -10000

CONFIG.pid.outLimit = 8;
CONFIG.pid.IntLimit = 0.2;

CONFIG.pwmOnOff = [1 1 1]; % motor PWM On (pwm_out = 1 * pwm_in) or Off (pwm_out = 0 * pwm_in)

% torso
% CONFIG.pid.Kp = [-1 -1 -1]; % -100 -100 -100
% CONFIG.pid.Kd =  [0 0 0]; %  0
% CONFIG.pid.Ki = [-1 -1 -1]; %  0
% 
% CONFIG.pid.outLimit = 8;
% CONFIG.pid.IntLimit = 0.5;
% 
% CONFIG.pwmOnOff = [1 1 1]; % motor PWM On (pwm_out = 1 * pwm_in) or Off (pwm_out = 0 * pwm_in)
