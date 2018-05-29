% definition of the Yarp ports where joint sensors and motion sensors
% (accelerometers, gyroscopes, IMUs and FT sensors) data is published.

joints_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/'' part ''/stateExt:o'']';
joints_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/'' part ''/stateExt:i'']';
joints_folder_rule_dumper =                       '[datapath ''/'' part ''/stateExt:o'']';

accSensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/'' part ''/inertialMTB'']';
accSensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/'' part ''/inertialMTB'']';
accSensors_folder_rule_dumper =                       '[datapath ''/'' part ''/inertialMTB'']';

imuSensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/inertial'']';
imuSensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/inertial'']';
imuSensors_folder_rule_dumper =            '[datapath ''/'' part ''/inertial'']';

FTSensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/'' part ''/analog:o'']';
FTSensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/'' part ''/analog:i'']';
FTSensors_folder_rule_dumper =                       '[datapath ''/'' part ''/analog:o'']';

xsensSensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/xsens_inertial'']';
xsensSensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/xsens_inertial'']';
xsensSensors_folder_rule_dumper =            '[datapath ''/'' part ''/xsens_inertial'']';

gyro8Sensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/'' part ''/inertialEMS8'']';
gyro8Sensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/'' part ''/inertialEMS8'']';
gyro8Sensors_folder_rule_dumper =                       '[datapath ''/'' part ''/inertialEMS8'']';

gyro9Sensors_port_rule_icub   =        '[''/'' robotYarpPortPrefix ''/'' part ''/inertialEMS9'']';
gyro9Sensors_port_rule_dumper = '[''/dumper/'' robotYarpPortPrefix ''/'' part ''/inertialEMS9'']';
gyro9Sensors_folder_rule_dumper =                       '[datapath ''/'' part ''/inertialEMS9'']';
