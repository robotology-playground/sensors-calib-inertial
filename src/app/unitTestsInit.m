%% clear all variables and close all previous figures
iDynTree.Vector3(); % WORKAROUND for being able to load yarp later.
clear
close all
clc

%Clear static data
clear classes;

% Create YARP Network device, for initializing YARP classes for communication
yarp.Network.init();

% load application main interface parameters
init = Init.load('sensorSelfCalibratorInit');
