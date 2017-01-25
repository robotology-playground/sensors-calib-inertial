% definition of the Yarp ports where joint sensors and motion sensors
% (accelerometers, gyroscopes, IMUs and FT sensors) data is published.

joints_port_rule_icub   =        '[''/'' robotname ''/'' part ''/stateExt:o'']';
joints_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/stateExt:i'']';

accSensors_port_rule_icub   =        '[''/'' robotname ''/'' part ''/inertialMTB'']';
accSensors_port_rule_dumper = '[''/dumper/'' robotname ''/'' part ''/inertialMTB'']';

imuSensors_port_rule_icub   =        '[''/'' robotname ''/inertial'']';
imuSensors_port_rule_dumper = '[''/dumper/'' robotname ''/inertial'']';
