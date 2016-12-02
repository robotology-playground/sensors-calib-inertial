%% some sensors are de-activated because of faulty behaviour, bad calibration or wrong frame definition
mtbSensorAct.left_arm(1:7) = {true};
mtbSensorAct.left_arm([3 5:7]) = {false};

mtbSensorAct.right_arm(1:7) = {true};
mtbSensorAct.right_arm([1 3 5:7]) = {false};

mtbSensorAct.left_leg(1:13) = {true};
%mtbSensorAct.left_leg(12:13) = {false};

mtbSensorAct.right_leg(1:13) = {true};
%mtbSensorAct.right_leg([6 7 12:13]) = {false};

mtbSensorAct.torso(1:4) = {false};

mtbSensorAct.head(1) = {true};

