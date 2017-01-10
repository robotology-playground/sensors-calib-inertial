%% init lists for motion sensors activation. Don't edit this section
%
mtbSensorAct.left_arm(1:7) = {false};
mtbSensorAct.right_arm(1:7) = {false};
mtbSensorAct.left_leg(1:13) = {false};
mtbSensorAct.right_leg(1:13) = {false};
mtbSensorAct.torso(1:4) = {false};
mtbSensorAct.head(1) = {false};

%% Select the joints to calibrate through the respective indexes in the port data
%
calibedJointsIdxes.left_arm = 1:4;
calibedJointsIdxes.right_arm = 1:4;
calibedJointsIdxes.left_leg = 1:6;
calibedJointsIdxes.right_leg = 1:6;
calibedJointsIdxes.torso = 1:3;
calibedJointsIdxes.head = 1:3;

%% Define parameters for all joints (calibrated or not)
%

% Optimization starting point
calibedJointsDq0.left_arm = [0 0 0 0];
calibedJointsDq0.right_arm = [0 0 0 0];
calibedJointsDq0.left_leg = [0 0 0 0 0 0];
calibedJointsDq0.right_leg = [0 0 0 0 0 0];
calibedJointsDq0.torso = [0 0 0];
calibedJointsDq0.head = [0 0 0];

%% some sensors are de-activated because of faulty behaviour, bad calibration 
%  or wrong frame definition

% set to 'true' activated sensors
mtbSensorAct.left_arm([1 2 4]) = {true};
mtbSensorAct.right_arm([2 4]) = {true};
mtbSensorAct.left_leg(1:13) = {true};
mtbSensorAct.right_leg(1:13) = {true};
mtbSensorAct.torso(1:4) = {true};
mtbSensorAct.head(1) = {true};
