% Set the Simulink model blocks main common parameters
% robotName, localName, Ts and ROBOT_DOF. ROBOT_DOF is parsed from the
% configuration file yarpWholeBodyInterface.ini defined for the current
% model.

robotName='icubGazeboSim';
localName='simulink';
ROBOT_DOF=23;
Ts=0.01;

qErr = zeros(ROBOT_DOF,1); qErr(:) = 0.3; % degrees
dqErr = zeros(ROBOT_DOF,1); dqErr(:) = 0.2; % degrees/s

% Parse the ROBOT_DOF
