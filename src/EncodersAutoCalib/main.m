%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

% 'simu' or 'target' mode
runMode = 'simu';
offsetsGridResolution = 10; % step between 2 offsets for each joint DOF (degrees)
offsetsGridRange = 5; % min/max (degrees)
offsetedQsIdxs = 1:6;

% model and data capture file
modelPath = '../models/iCubGenova02/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova02_#1/';

% Optimisation configuration
[optimFunction,options] = getOptimConfig();
startPoint2Boundary = 20*pi/180; % 20 deg
% cost function: 'costFunctionSigma' / 'costFunctionSigmaProjOnEachLink'
costFunctionSelect = 'costFunctionSigma';

% The main single data bucket of (timeStop-timeStart)/10ms samples is sub-sampled to
% 'subSamplingSize' samples. A subset of 'subSamplingSize*subsetVec_size_frac' is
% then selected for running the optimisation on.
% The subset can be selected randomly.
number_of_subset_init = 1;
subsetVec_size_frac = 0.5; % subset size = 1/10 total data set size
timeStart = 2;  % starting time in capture data file (in seconds)
timeStop  = 28; % ending time in capture data file (in seconds)
subSamplingSize = 1000; % number of samples after sub-sampling the raw data

% define the set of joints (of whole limb) to calibrate and activate the sensors
% in that limb.
jointsToCalibrate.parts = {'left_leg'};

mtbSensorAct_left_leg = {false,false, ...
                         true,true, ...
                         false, ...
                         true,true, ...
                         true,false,   ...
                         false,false,   ...
                         true};
%mtbSensorAct_left_leg(:) = {true};

%%=========================================================================

%% set init parameters
%

if strcmp(runMode,'target')
    offsetsGridRange = 0;
    offsetedQsIdxs = 1;
end

jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};
run jointsNsensorsDefinitions;

% create the calibration context implementing the cost function
myCalibContext = CalibrationContextBuilder(modelPath);

% Cost Function used to optimise the offsets
eval(['costFunction = @myCalibContext.' costFunctionSelect]);


%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)

    % Joint codes and links for current part are:
    % mtbSensorCodes_list{part}
    % mtbSensorLink_list{part};
    nrOfMTBAccs = length(mtbSensorLink_list{part});

    %% Parsing configuration
    %
    switch runMode
        case 'simu'
            load 'dataSimu.mat';
        case 'target'
            % build sensor data parser ('inputFilePath',nbSamples,tInit,tEnd,plot--true/false)
            data = SensorsData(dataPath,subSamplingSize,timeStart,timeStop,false);
            
            % add mtb sensors
            data.addMTBsensToData(jointsToCalibrate.parts{part}, 1:nrOfMTBAccs, ...
                mtbSensorCodes_list{part}, mtbSensorLink_list{part}, ...
                mtbSensorAct_left_leg, jointsToCalibrate.mtbInvertedFrames{part},true);
            
            % add joint measurements
            data.addEncSensToData(jointsToCalibrate.parts{part}, true);
            
            % Load data from the file and parse it
            data.loadData();
        otherwise
            disp('Unknown run mode !!')
    end
    
    %% init joints and sensors lists
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data,part,jointsToCalibrate);
    
    
    %% Optimization
    %
    
    % init variables considered independent from the offsets
    subsetVec_size = round(data.nSamples*subsetVec_size_frac);
    subsetVec_idx = round(linspace(1,data.nSamples,subsetVec_size));
    Dq0 = cell2mat(jointsToCalibrate.jointsDq0(part))';
    lowerBoundary = Dq0 - startPoint2Boundary;
    upperBoundary = Dq0 + startPoint2Boundary;
    
    % Build the offsets grid
    offsetsConfigGrid = nDimGrid(length(offsetedQsIdxs), ...
                                 offsetsGridRange, ...
                                 offsetsGridResolution);
    % iterate over the joints offsets grid values
    for offsetsConfigIdx = 1:offsetsConfigGrid.nbVectors
        
        optimalDq = zeros(length(Dq0),number_of_subset_init,offsetsConfigGrid.nbVectors);
        resnorm = zeros(1,number_of_subset_init,offsetsConfigGrid.nbVectors);
        exitflag = zeros(1,number_of_subset_init,offsetsConfigGrid.nbVectors);
        
        % set the offsets from grid
        myCalibContext.DqiEnc(offsetedQsIdxs) = offsetsConfigGrid.getVector(offsetsConfigIdx);
        
        % run minimisation for every random subset of data.
        % 1 subset <=> all measurements for a given timestamp <=>1 column index of
        % table `q_xxx`, `dq_xxx`, `ddq_xxx`, `y_xxx_acc`, ...
        for i = 1 : number_of_subset_init
            
            % define a random subset: 10 % of the total set of instants
            %subsetVec_idx = randsample(data.nSamples, subsetVec_size);
            %subsetVec_idx = sort(subsetVec_idx);
            
            % load joint positions
            myCalibContext.loadJointNsensorsDataSubset(data,subsetVec_idx);
            
            % optimize
            funcProps = functions(optimFunction);
            funcName = funcProps.function;
            switch funcName
                case 'fminunc'
                    [optimalDq(:,i,offsetsConfigIdx),  resnorm(1,i,offsetsConfigIdx), ...
                        exitflag(1,i,offsetsConfigIdx), output(1,i,offsetsConfigIdx)] ...
                        = optimFunction(@(Dq) costFunction(Dq,data,subsetVec_idx,optimFunction), ...
                        Dq0, options);
                case 'lsqnonlin'
                    [optimalDq(:,i,offsetsConfigIdx), resnorm(1,i,offsetsConfigIdx), ~, ...
                        exitflag(1,i,offsetsConfigIdx), output(1,i,offsetsConfigIdx), ~] ...
                        = optimFunction(@(Dq) costFunction(Dq,data,subsetVec_idx,optimFunction), ...
                        Dq0, lowerBoundary, upperBoundary, options);
                otherwise
            end
            optimalDq(:,i,offsetsConfigIdx) = mod(optimalDq(:,i,offsetsConfigIdx)+pi, 2*pi)-pi;
            % remove known offset (useful in simulation run mode)
            optimalDq(:,i,offsetsConfigIdx) = optimalDq(:,i,offsetsConfigIdx) - myCalibContext.DqiEnc;
            % convert to degrees
            optimalDq(:,i,offsetsConfigIdx) = optimalDq(:,i,offsetsConfigIdx)*180/pi;
        end
    end
    % Standard deviation (!!!!! across offsets grid, NOT buckets anymore !!!!!!)
    std_optDq = std(optimalDq,0,3);
    
    fprintf('Final optimization results. Each column stands for a random init of the data subset.\n');
    fprintf('Optimal offsets Dq (in radians):\n');
    optimalDq
    fprintf('Mean cost (in (m.s^{-2})^2):\n');
     resnorm/(nrOfMTBAccs*length(subsetVec_idx))
    fprintf('optimization function exit flag:\n');
    exitflag
    fprintf('other optimization info:\n');
    output
    fprintf('Standard deviation for each joint offset:\n');
    std_optDq
    
end


save('./data/minimResult.mat','optimalDq','exitflag','output','std_optDq','data');
