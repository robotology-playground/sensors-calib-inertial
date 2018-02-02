% definition of the Yarp ports where joint sensors and motion sensors
% (accelerometers, gyroscopes, IMUs and FT sensors) data is published.

joints_port_rule_icub   =        '[''/'' robotname ''/'' part ''/stateExt:o'']';
joints_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/stateExt:i'']';
joints_folder_rule_dumper =             '[datapath ''/'' part ''/stateExt:o'']';

accSensors_port_rule_icub   =        '[''/'' robotname ''/'' part ''/inertialMTB'']';
accSensors_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/inertialMTB'']';
accSensors_folder_rule_dumper =             '[datapath ''/'' part ''/inertialMTB'']';

imuSensors_port_rule_icub   =        '[''/'' robotname ''/inertial'']';
imuSensors_port_rule_dumper = '[''/dumper/'' robotname ''/inertial'']';
imuSensors_folder_rule_dumper =  '[datapath ''/'' part ''/inertial'']';

FTSensors_port_rule_icub   =        '[''/'' robotname ''/'' part ''/analog:o'']';
FTSensors_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/analog:i'']';
FTSensors_folder_rule_dumper =             '[datapath ''/'' part ''/analog:o'']';

xsensSensors_port_rule_icub   =        '[''/'' robotname ''/xsens_inertial'']';
xsensSensors_port_rule_dumper = '[''/dumper/'' robotname ''/xsens_inertial'']';
xsensSensors_folder_rule_dumper =  '[datapath ''/'' part ''/xsens_inertial'']';

gyro8Sensors_port_rule_icub   =        '[''/'' robotname ''/'' part ''/inertialEMS8'']';
gyro8Sensors_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/inertialEMS8'']';
gyro8Sensors_folder_rule_dumper =             '[datapath ''/'' part ''/inertialEMS8'']';

gyro9Sensors_port_rule_icub   =        '[''/'' robotname ''/'' part ''/inertialEMS9'']';
gyro9Sensors_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/inertialEMS9'']';
gyro9Sensors_folder_rule_dumper =             '[datapath ''/'' part ''/inertialEMS9'']';
