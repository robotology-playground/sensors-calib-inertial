clear
close all
clc

%% define the joints to calibrate and the sensor codes and links they are attached to
jointsToCalibrate.parts = {'left_leg'};
jointsToCalibrate.partJoints = {};
jointsToCalibrate.partJointsInitOffsets = {};
mtbSensorCodes_list = {};
mtbSensorLink_list = {};

run jointsNsensorsDefinitions;


%% define offsets for parsing Linear Acceleration data from MTB accelerometers
%
% Refer to wiki:
% https://github.com/robotology/codyco-modules/wiki/External-Inertial-Sensors-for-iCubGenova02
%
% a = (n  6.0  (a1  b1 t1 x1 y1 z1)   .... (an  bn tn xn yn xn))
% n  = number of sensors published on the port
% ai = pos of sensor ... see enum type
% bi = accel (1) or gyro (2)
% ti = ?
% 
% | size  | 1 |  1  |   6  |            6           | ...
% | offset| 1 |  2  | 3..8 |2+6*(i-1)+1..2+6*(i-1)+6| ...
% | Field | n | 6.0 |a1..z1| ai  bi  ti  xi  yi  zi | ...
%
HEADER_LENGTH = 2;
FULL_ACC_SIZE = 6;
LIN_ACC_1RST_IDX = 4;
LIN_ACC_LAST_IDX = 6;


%% PROCESS EACH PART INDEPENDENTLY
%
for part = 1 : length(jointsToCalibrate.parts)

    %% define joint codes and links for current part
    %
    mtbSensorCodes = mtbSensorCodes_list{part};
    mtbSensorLink = mtbSensorLink_list{part};
    
    %% generate indices and labels for the mtb sensors (Accelerometers)
    %
    nrOfMTBAccs = length(mtbSensorLink);
    mtbIndices = {};
    for i = 1:nrOfMTBAccs
        % Indexes for linear acceleration
        mtbIndices{i} = strcat(num2str(HEADER_LENGTH+FULL_ACC_SIZE*(i-1)+LIN_ACC_1RST_IDX), ...
            ':', ...
            num2str(HEADER_LENGTH+FULL_ACC_SIZE*(i-1)+LIN_ACC_LAST_IDX));
    end

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


    % some sensor are inverted in the model with respect to how are mounted on
    % the real robot
    mtbInvertedFrames   =  {true,true, ...
        true,true, ...
        true, ...
        false,false, ...
        true,true,   ...
        true,true,   ...
        false,false};




    %% Parsing configuration
    %
    % the fields of "data" are created here on the fly.
    %
    data.nsamples  = 1000; %number of samples
    data.plot      = 0;
    data.ini       = 2;    %seconds to be skipped at the start
    data.end       = 28;   %seconds to reach the end of the movement
    data.diff_imu  = 0;    %derivate the angular velocity of the IMUs
    data.diff_q    = 0;    %derivate the angular velocity of the IMUs


    %% strucutre from files
    data.path        = '../../data/calibration/dumper/iCubGenova02_#1/';
    data.parts       = {};
    data.labels      = {};
    data.frames      = {};
    data.ndof        = {};
    data.index       = {};
    data.type        = {};
    data.visualize   = {};

    %% strucutre for urdf
    sens.parts       = {};
    sens.labels      = {};
    sens.ndof        = {};
    sens.type        = {};
    sens.transform  = {};

    %% add mtb sensors
    for i = 1:nrOfMTBAccs
        data = addSensToData(data, jointsToCalibrate.parts{part}, mtbSensorFrames{i}, mtbSensorLabel{i}  , 3, mtbIndices{i}, 'inertialMTB', 1*data.plot);
    end

    %% add joint measurements
    data = addSensToData(data, jointsToCalibrate.parts{part}, '', [jointsToCalibrate.parts{part} '_state'], 6, '1:6', 'stateExt:o' , 1*data.plot);

    data = loadData(data);


    %% Create the estimator and model...
    %
    % Create an estimator class, load the respective model from URDF file and
    % set the robot state constant parameters

    % Create estimator class
    estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();

    % Load model and sensors from the URDF file
    estimator.loadModelAndSensorsFromFile('../models/iCubGenova02/iCubFull.urdf');

    % Check if the model was correctly created by printing the model
    estimator.model().toString()

    %% Optimization
    %

    number_of_random_init = 5;
    subsetVec_size = round(data.nsamples*0.1);
    Dq0 = cell2mat(jointsToCalibrate.partJointsInitOffsets(part))';
    
    % run minimisation for every random subset of data.
    % 1 subset <=> all measurements for a given timestamp <=>1 column index of
    % table `q_xxx`, `dq_xxx`, `ddq_xxx`, `y_xxx_acc`, ...
    for i = 1 : number_of_random_init
        
        % define a random subset: 10 % of the total set of instants
        subsetVec_idx = randsample(data.nsamples, subsetVec_size);
        subsetVec_idx = sort(subsetVec_idx);
        
        % Optimization options: we won't provide the gradient for now
        %
        % For FUNCTION 'fminunc'
        % Display: 'iter'
        % MaxFunEvals:
        % MaxIter:
        % TolFun:  1e-7
        % TolX: 0.1 (Encoders accuracy => 12 bits for 360 deg => 1 tick =
        % 0.087 deg ~ 0.1 deg)
        % FunValCheck: 'on'
        % ActiveConstrTol:
        % Algorithm: 'interior-point'
        % AlwaysHonorConstraints:
        % GradConstr:
        % GradObj:
        % InitTrustRegionRadius:
        % LargeScale:
        % ScaleProblem:
        % SubproblemAlgorithm:
        % UseParallel:
        % PlotFcns : {@optimplotx, @optimplotfval, @optimplotstepsize}
        %
        options = optimset('Algorithm','interior-point', ...
            'TolFun', 1e-7, 'TolX', 1e-1, 'FunValCheck', 'on', ...
            'Display', 'iter', 'PlotFcns', {@optimplotx, @optimplotfval, @optimplotstepsize});
        
        % optimize
        [optimalDq(:, i), fval(i), exitflag(i), output(i)] = fminunc(@(Dq) costFunctionSigma(Dq, part, jointsToCalibrate, ...
                                                                                             data, subsetVec_idx, estimator), ...
                                                                     Dq0, options);
        optimalDq(:, i) = mod(optimalDq(:, i)+pi, 2*pi)-pi;
    end
    
    optimalDq
    fval
    exitflag
    output
    
    std_optDq = std(optimalDq,0,2)

end

