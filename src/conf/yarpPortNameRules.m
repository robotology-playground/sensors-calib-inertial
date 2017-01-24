% definition of the Yarp ports where joint sensors and motion sensors
% (accelerometers, gyroscopes, IMUs and FT sensors) data is published.

parts =      {'left_leg','right_leg','left_arm','right_arm','torso','head'};

sensorType = {'acc','acc','acc','acc','acc','imu'};

joints_port_rule = '[''/'' robotname ''/'' part ''/stateExt:o'']';

accSensors_port_rule = '[''/'' robotname ''/'' part ''/inertialMTB'']';

imuSensors_port_rule = '[''/'' robotname ''/inertial'']';
