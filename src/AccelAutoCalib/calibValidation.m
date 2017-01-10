%%         Calibration Validation on several datasets
%
%
%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

run calibValidationInit;

%% set init parameters 'ModelParams'
%
run jointsNsensorsSelectionsForValidation;
ModelParams = jointsNsensorsDefinitions(parts,calibedJointsIdxes,calibedJointsDq0,mtbSensorAct);

%% Update iterator and prepare log folders/files
%
if logTest
    if exist('./data/test/iterator.mat','file') == 2
        load('./data/test/iterator.mat','iterator');
        iterator = iterator+1;
    end
    save('./data/test/iterator.mat','iterator');
    
    figsFolder = ['./data/test/log_' num2str(iterator)];
    dataFolder = ['./data/test'];
    system(['mkdir ' dataFolder],'-echo')
    system(['mkdir ' figsFolder],'-echo')
    fileID = fopen([dataFolder '/log_' num2str(iterator) '.txt'],'w');
    fprintf(fileID,'modelPath = %s\n',modelPath);
    fprintf(fileID,'dataPath = %s\n',dataPath);
    fprintf(fileID,'dataSetNb = %s\n',dataSetNb);
    fprintf(fileID,'calibrationMapFile = %s\n',calibrationMapFile);
    fprintf(fileID,'iterator = %d\n',iterator);
    fclose(fileID);
end

%% ===================================== CALIBRATION VALIDATION ==============================
%

%% build input data before calibration
%
switch loadSource
    case 'matFile'
        load './data/dataCache.mat';
    case 'dumpFile'
        % Build input data without calibration applied
        [data.bc,sensorsIdxListFile,sensMeasCell.bc] = buildInputDataSet(...
            'dumpFile',false,loadJointPos,...
            dataPath,dataSetNb,...
            subSamplingSize,timeStart,timeStop,...
            ModelParams);
        
        %% Apply calibration and reload input data
        %
        
        % Load existing calibration
        if exist(calibrationMapFile,'file') == 2
            load(calibrationMapFile,'calibrationMap');
        end
        
        if ~exist('calibrationMap','var')
            error('calibrationMap not found');
        end
        
        % Build input data with calibration applied
        [data.ac,sensorsIdxListFile,sensMeasCell.ac] = buildInputDataSet(...
            'dumpFile',false,false,...
            dataPath,dataSetNb,...
            subSamplingSize,timeStart,timeStop,...
            ModelParams,calibrationMap);
        
        % Save data in a Matlab file for faster access in further runs
        if saveToCache
            save('./data/dataCache.mat','data','sensorsIdxListFile','sensMeasCell');
        end
    otherwise
        disp('Unknown data source !!')
end

% iteration list
%activeAccs = ModelParams.mtbSensorCodes_list{1}(cell2mat(ModelParams.mtbSensorAct_list));


%% Check anysotropy of gains and offsets
%
% checkAccelerometersAnysotropy(...
%     data.bc,data.ac,sensorsIdxListFile,...
%     sensMeasCell.bc,sensMeasCell.ac,...
%     figsFolder,logTest,loadJointPos);

if loadJointPos
    %% Generate predicted measurements
    %
    % create the calibration context implementing the cost function
    myCalibContext = CalibrationContextBuilder(modelPath);
    costFunction = @myCalibContext.costFunctionSigma;
    nrOfMTBAccs = length(sensorsIdxListFile);

    % init joints and sensors lists
    for part = 1 : length(ModelParams.parts)
        myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data.bc,part,ModelParams);
    end
    
    % load joint positions
    myCalibContext.loadJointNsensorsDataSubset(1:data.bc.nSamples);
    
    % cost before calibration
    [initialCost,sensMeasCell.bc,sensEstCell.bc] = costFunction(0,data.bc,1:data.bc.nSamples,@lsqnonlin,false,'');
    fprintf('Mean cost before optimization (in (m.s^{-2})^2):\n');
    (initialCost'*initialCost)/(nrOfMTBAccs*data.bc.nSamples)
    
    % cost after calibration
    [finalCost,sensMeasCell.ac,sensEstCell.ac] = costFunction(0,data.ac,1:data.ac.nSamples,@lsqnonlin,false,'');
    fprintf('Mean cost before optimization (in (m.s^{-2})^2):\n');
    (finalCost'*finalCost)/(nrOfMTBAccs*data.ac.nSamples)

    %% Plot joint trajectories
    %
    plotJointTrajectories(data,ModelParams,figsFolder,logTest);
    
    %% Plot predicted sensor variables VS sensor sensor measurements
    %
    checkSensorMeasVsEst(...
        data,sensorsIdxListFile,...
        sensMeasCell.bc,sensEstCell.bc,...
        figsFolder,logTest,'bc')
    checkSensorMeasVsEst(...
        data,sensorsIdxListFile,...
        sensMeasCell.ac,sensEstCell.ac,...
        figsFolder,logTest,'ac')
end

%% Log all data
if logTest
    save([dataFolder '/log_' num2str(iterator) '_All.mat']);
end 

