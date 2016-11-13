%% DEBUG
% jointsToCalibrate.parts = {'left_arm','right_arm','left_leg','right_leg','torso','head'};

%% Select the joints to calibrate through the respective indexes in the port data
%
jointsIdxes_left_arm = '1:3';
jointsIdxes_right_arm = '1:3';
jointsIdxes_left_leg = '1:6';
jointsIdxes_right_leg = '1:6';
jointsIdxes_torso = '1:3';
jointsIdxes_head = '1:3';

%% Define parameters for all joints (calibrated or not)
%

% Optimization starting point
jointsDq0_left_arm = [0 0 0 0];
jointsDq0_right_arm = [0 0 0 0];
jointsDq0_left_leg = [0 0 0 0 0 0];
jointsDq0_right_leg = [0 0 0 0 0 0];
jointsDq0_torso = [0 0 0];
jointsDq0_head = [0 0 0];

% pre-computed optimal joint offsets
averageOptimalDq = 0;

%% some sensors are de-activated because of faulty behaviour, bad calibration or wrong frame definition
mtbSensorAct_left_arm(1:7) = {true};
mtbSensorAct_left_arm([3 5:7]) = {false};

mtbSensorAct_right_arm(1:7) = {true};
mtbSensorAct_right_arm([1 3 5:7]) = {false};

mtbSensorAct_left_leg(1:13) = {true};
mtbSensorAct_left_leg(12:13) = {false};

mtbSensorAct_right_leg(1:13) = {true};
mtbSensorAct_right_leg([6 7 12:13]) = {false};

mtbSensorAct_torso(1:4) = {false};

mtbSensorAct_head(1) = {true};

