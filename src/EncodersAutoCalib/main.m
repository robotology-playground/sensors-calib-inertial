%% clear all variables and close all previous figures
clear
close all
clc

%% Global parameters

% Optimisation configuration
[optimFunction,options] = getOptimConfig();
startPoint2Boundary = 20*pi/180; % 20 deg

% A random init selects randomly an ordered subset of samples from the whole data
% set bucket.
number_of_random_init = 1;
subsetVec_size_frac = 0.1; % subset size = 1/10 total data set size


%% define the joints to calibrate and the sensor codes and links they are attached to
jointsToCalibrate.parts = {'left_leg'};
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};

mtbSensorAct_left_leg = {false,false, ...
                         true,true, ...
                         false, ...
                         true,true, ...
                         true,false,   ...
                         false,false,   ...
                         true};
%mtbSensorAct_left_leg(:) = {true};

run jointsNsensorsDefinitions;

% create the calibration context implementing the cost function
myCalibContext = CalibrationContextBuilder('../models/iCubGenova02/iCubFull.urdf');

% Cost Function used to optimise the offsets
costFunction = @myCalibContext.costFunctionSigma;
%costFunction = @myCalibContext.costFunctionSigmaProjOnEachLink;


%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)

    %% joint codes and links for current part are:
    % mtbSensorCodes_list{part}
    % mtbSensorLink_list{part};
    nrOfMTBAccs = length(mtbSensorLink_list{part});

    %% Parsing configuration
    %
    % build sensor data parser ('inputFilePath',nbSamples,tInit,tEnd,plot--true/false)
    data = SensorsData('../../data/calibration/dumper/iCubGenova02_#1/',1000,2,28,false);

    %% add mtb sensors
    data.addMTBsensToData(jointsToCalibrate.parts{part}, 1:nrOfMTBAccs, ...
                          mtbSensorCodes_list{part}, mtbSensorLink_list{part}, ...
                          mtbSensorAct_left_leg, jointsToCalibrate.mtbInvertedFrames{part},true);

    %% add joint measurements
    data.addEncSensToData(jointsToCalibrate.parts{part}, true);

    % Load data from the file and parse it
    data.loadData();

    %% init joints and sensors lists
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data,part,jointsToCalibrate);
    
    
    %% Optimization
    %

    subsetVec_size = round(data.nSamples*subsetVec_size_frac);
    Dq0 = cell2mat(jointsToCalibrate.jointsDq0(part))';
    lowerBoundary = Dq0 - startPoint2Boundary;
    upperBoundary = Dq0 + startPoint2Boundary;
    %lowerBoundary = [];
    %upperBoundary = [];
    optimalDq = zeros(length(Dq0),number_of_random_init);
    resnorm = zeros(1,number_of_random_init);
    exitflag = zeros(1,number_of_random_init);
    
    % run minimisation for every random subset of data.
    % 1 subset <=> all measurements for a given timestamp <=>1 column index of
    % table `q_xxx`, `dq_xxx`, `ddq_xxx`, `y_xxx_acc`, ...
    for i = 1 : number_of_random_init
        
        % define a random subset: 10 % of the total set of instants
        subsetVec_idx = randsample(data.nSamples, subsetVec_size);
        subsetVec_idx = sort(subsetVec_idx);
        
        % load joint positions
        myCalibContext.loadJointNsensorsDataSubset(data,subsetVec_idx);
        
        % optimize
        funcProps = functions(optimFunction);
        funcName = funcProps.function;
        switch funcName
            case 'fminunc'
                [optimalDq(:, i),  resnorm(1,i), exitflag(1,i), output(1,i)] ...
                    = optimFunction(@(Dq) costFunction(Dq,data,subsetVec_idx,optimFunction), ...
                                    Dq0, options);
            case 'lsqnonlin'
                [optimalDq(:, i), resnorm(1,i), ~, exitflag(1,i), output(1,i), lambda(1,i)] ...
                    = optimFunction(@(Dq) costFunction(Dq,data,subsetVec_idx,optimFunction), ...
                                    Dq0, lowerBoundary, upperBoundary, options);
            otherwise
        end
        optimalDq(:, i) = mod(optimalDq(:, i)+pi, 2*pi)-pi;
    end
    
    % Standard deviation
    std_optDq = std(optimalDq,0,2);
    
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
