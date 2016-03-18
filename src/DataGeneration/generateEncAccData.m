% this script generates joint encoders and accelerometers measurements data
% by simulating a trajectory and using measurement predictions. this
% simulation is based on the specified iCub model.

%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

% offsets simulation parameters
offsetsGridResolution = 1*pi/180; % step between 2 offsets for each joint DOF (degrees)
offsetsGridRange = 5*pi/180; % min/max (degrees)
offsetedQsIdxs = [1 4 5];

% model and data capture file
modelPath = '../models/iCubGenova02/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova02_#1/';

% cost function: 'costFunctionSigma' / 'costFunctionSigmaProjOnEachLink'
costFunctionSelect = 'costFunctionSigma';
% optimisation function name (just for shaping the output of the cost
% function 'fminunc', 'fmincon', 'lsqnonlin', 'none' ...
optimFunc = @fminunc;

% sensor data parameters
subsetVec_size_frac = 0.1; % subset size = 1/10 total data set size
timeStart = 2;  % starting time in capture data file (in seconds)
timeStop  = 28; % ending time in capture data file (in seconds)
subSamplingSize = 1000; % number of samples after sub-sampling the raw data

% define the set of joints (of whole limb) to calibrate.
% All sensors in that limb are activated.
jointsToCalibrate.parts = {'left_leg'};

%% set init parameters from interface, create model, load parameters from the 
%  specified URDF
%
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};
run ../EncodersAutoCalib/jointsNsensorsDefinitions;


% create the calibration context implementing the cost function
myCalibContext = CalibrationContextBuilder(modelPath);

% Cost Function used to optimise the offsets
eval(['costFunction = @myCalibContext.' costFunctionSelect]);


%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)

    %% joint codes and links for current part are:
    % mtbSensorCodes_list{part}
    % mtbSensorLink_list{part};
    nrOfMTBAccs = length(mtbSensorLink_list{part});

    % We will generate data for all sensors, so "activate" all of them.
    mtbSensorAct = cell(1,length(mtbSensorCodes_list{part}));
    mtbSensorAct(:,:) = {true};

    %% Parsing configuration
    %
    % build sensor data parser ('inputFilePath',nbSamples,tInit,tEnd,plot--true/false)
    data = SensorsData(dataPath,subSamplingSize,timeStart,timeStop,false);

    % add joint measurements
    data.addEncSensToData(jointsToCalibrate.parts{part}, true);

    % Load data from the file and parse it
    data.loadData();

    % add mtb sensors
    data.addMTBsensToData(jointsToCalibrate.parts{part}, 1:nrOfMTBAccs, ...
                          mtbSensorCodes_list{part}, mtbSensorLink_list{part}, ...
                          mtbSensorAct, jointsToCalibrate.mtbInvertedFrames{part},true);

    %% init joints and sensors lists & load joint data
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data,part,jointsToCalibrate);

    % load joint positions
    vecIdx = 1:data.nSamples;
    myCalibContext.loadJointNsensorsDataSubset(data,vecIdx);
    
    %% iterate over all the samples and generate sensor estimations
    myCalibContext.simulateAccelerometersMeasurements(data,vecIdx);
    
    %save ('dataSimu.mat','data');
    
    %% Offsets Simulation and plotting
    % simulate offseted encoder measurements, apply them to the cost
    % function computation and plot the results
    
    % init variables considered independent from the offsets
    subsetVec_size = round(data.nSamples*subsetVec_size_frac);
    subsetVec_idx = round(linspace(1,data.nSamples,subsetVec_size));
    
    % Build the offsets grid
    offsetsConfigGrid = nDimGrid(length(offsetedQsIdxs), ...
                                 offsetsGridRange, ...
                                 offsetsGridResolution)
    
    % define and init cost grid
    e = zeros(size(offsetsConfigGrid.grid{1}));
    flatE = zeros(offsetsConfigGrid.nbVectors,1);

    % myCalibContext.DqiEnc is already initialized;
    Dq = zeros(length(jointsToCalibrate.partJointsInitOffsets{part}),1);

    % iterate over the joints offsets grid values
    for offsetsConfigIdx = 1:offsetsConfigGrid.nbVectors
        
        % set the offsets from grid
        myCalibContext.DqiEnc(offsetedQsIdxs) = offsetsConfigGrid.getVector(offsetsConfigIdx);
        % load joint positions
        myCalibContext.loadJointNsensorsDataSubset(data,subsetVec_idx);
        % compute cost
        e(offsetsConfigIdx) = costFunction(Dq,data,subsetVec_idx,optimFunc);
        flatE(offsetsConfigIdx) = e(offsetsConfigIdx);
        disp(e(offsetsConfigIdx));
        
    end

    %% format 'e' results in order to create parallel coordinates plots
    % - create a linear scale from min(e) to max(e)
    % - the +1 is for avoiding exceeding the max index
    linearE = linspace(min(flatE),max(flatE)+1,length(flatE)/40);
    linearEstep = (max(linearE)-min(linearE))/length(linearE);
    %% map the linear cost 'linearE' to the original cost 'flatE'
    flatE_2_linearE = div((flatE - min(linearE)),linearEstep) + 1;
    linearE_2_flatE = cell(1,length(linearE));
    %% run across 'flatE_2_linearE' and save the current index in
    % the respective 'linearE_2_flatE' cluster
    for iter = 1:length(flatE)
        linearE_2_flatE{1,flatE_2_linearE(iter)}(1,end+1) = iter;
    end
    
    % remove empty elements from 'linearE_2_flatE' and respective elements
    % in 'linearE'
    nonEmptyElts = ~cellfun('isempty',linearE_2_flatE);
    linearE_2_flatE = linearE_2_flatE(nonEmptyElts);
    linearE = linearE(nonEmptyElts);
    
    %% compute the mean point and the std for each cluster
    e_meanDq = zeros(length(offsetedQsIdxs),length(linearE));
    e_std = zeros(size(e_meanDq));
    e_single_std = zeros(1,length(linearE));
    
    for iter = 1:length(linearE)
        idxs = linearE_2_flatE{1,iter};
        % get repective Dq matrix: dim 1 is dim of q, dim 2 is the number
        % of points Dq's that have the same selected cost 'flatE'.
        DqMat = offsetsConfigGrid.getVector(idxs);
        e_meanDq(:,iter) = mean(DqMat,2)*(180/pi);
        e_std(:,iter) = std(DqMat,0,2)*(180/pi);
        e_single_std(iter) = e_std(:,iter)'*e_std(:,iter)*((180/pi)^2);
    end
    
    %% save all variables
    save(num2str(offsetedQsIdxs,'./data/gridResults1_q%i-%i-%i.mat'));
    
end
