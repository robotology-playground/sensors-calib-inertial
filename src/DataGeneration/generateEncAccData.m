% this script generates joint encoders and accelerometers measurements data
% by simulating a trajectory and using measurement predictions. this
% simulation is based on the specified iCub model.

%% clear all variables and close all previous figures
clear
close all
clc

%% define: the joints for which we want to generate accelerometer data; 
%          the sensor codes and links these sensors are attached to
modelPath = '../models/iCubGenova02/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova02_#1/';

jointsToCalibrate.parts = {'left_leg'};
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};

run ../EncodersAutoCalib/jointsNsensorsDefinitions;

%% create model, load parameters from the specified URDF
%
myCalibContext = CalibrationContextBuilder(modelPath);

%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)
    
    %% define joint codes and links for current part
    %
    mtbSensorCodes = mtbSensorCodes_list{part};
    mtbSensorLink = mtbSensorLink_list{part};
    
    % We will generate data for all sensors, so "activate" all of them.
    mtbSensorAct = repmat(true,1,length(mtbSensorCodes_list{part}));

    %% generate labels for the mtb sensors (Accelerometers)
    %
    nrOfMTBAccs = length(mtbSensorLink);
    mtbIndices = {};
    mtbSensorFrames = {};
    for i = 1:nrOfMTBAccs
        % there is no naming convention yet. ex of sensor frame:
        % [r_upper_leg_mtb_acc_11b3]
        mtbSensorFrames{i} = strcat(mtbSensorLink{i},'_mtb_acc_',mtbSensorCodes{i});
    end

    mtbSensorLabel = {};
    for i = 1:nrOfMTBAccs
        % ex of sensor label:
        % [11b3_acc]
        mtbSensorLabel{i} = strcat(mtbSensorCodes{i},'_acc');
    end


    %% Parsing configuration
    %
    % the fields of "data" are created here on the fly.
    %
    data.nsamples  = 1000; %number of samples
    data.plot      = 0;
    data.ini       = 130;    %seconds to be skipped at the start
    data.end       = 140;   %seconds to reach the end of the movement
    data.diff_imu  = 0;    %derivate the angular velocity of the IMUs
    data.diff_q    = 0;    %derivate the angular velocity of the IMUs


    %% strucutre from files and model
    data.path        = '../../data/calibration/dumper/iCubGenova02_#1/';
    data.parts       = {};
    data.labels      = {};
    data.frames      = {};
    data.sensorAct   = {};
    data.isInverted  = {};
    data.ndof        = {};
    data.index       = {};
    data.type        = {};
    data.visualize   = {};

    %% add joint measurements
    data = addSensToData(data, jointsToCalibrate.parts{part}, '', [jointsToCalibrate.parts{part} '_state'] , true, 6, '1:6', 'stateExt:o' , 1*data.plot);

    data = loadData(data);

    %% add mtb sensors
    for i = 1:nrOfMTBAccs
        data = addSensToData(data, jointsToCalibrate.parts{part}, mtbSensorFrames{i}, mtbSensorLabel{i} , mtbSensorAct(i), 3, '', 'inertialMTB', 1*data.plot);
    end


    %% init joints and sensors lists & load joint data
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data,part,jointsToCalibrate);
    
    % load joint positions
    vecIdx = 1:data.nsamples;
    myCalibContext.loadJointNsensorsDataSubset(data,vecIdx);
    
    %% iterate over all the samples and generate sensor estimations
    myCalibContext.simulateAccelerometersMeasurements(data,vecIdx);
    
    save ('data','dataSimu');
    
end
