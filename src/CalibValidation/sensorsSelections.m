%% init lists for motion sensors activation. Don't edit this section
%
mtbSensorAct.left_arm(1:7) = {false};
mtbSensorAct.right_arm(1:7) = {false};
mtbSensorAct.left_leg(1:13) = {false};
mtbSensorAct.right_leg(1:13) = {false};
mtbSensorAct.torso(1:4) = {false};
mtbSensorAct.head(1) = {false};

%% some sensors are de-activated because of faulty behaviour, bad calibration 
%  or wrong frame definition

% set to 'true' activated sensors
mtbSensorAct.left_arm([1 2 4]) = {true};
mtbSensorAct.right_arm([2 4]) = {true};
mtbSensorAct.left_leg(1:13) = {true};
mtbSensorAct.right_leg(1:13) = {true};
mtbSensorAct.torso(1:4) = {true};
mtbSensorAct.head(1) = {true};
