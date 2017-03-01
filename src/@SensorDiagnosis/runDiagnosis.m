function runDiagnosis(...
    modelPath,calibrationMap,...
    taskSpecificParams,dataPath,...
    measedSensorList,measedPartsList)

% Unwrap task specific parameters (defines 'calibedJointsIdxes')
Init.unWrap(taskSpecificParams);

% Advanced interface parameters
run sensorDiagnosisDevConfig;

%% set init parameters 'modelParams'
%
modelParams = CalibrationContextBuilder.jointsNsensorsDefinitions(...
    measedSensorList,measedPartsList,...
    {},[],[],...
    mtbSensorAct);

%% Update iterator and prepare log folders/files
%
if savePlot
    % create folders
    dataFolder = [dataPath '/diag'];
    figsFolder = [dataFolder '/log_' num2str(iterator)];
    mkdir(dataFolder);
    mkdir(figsFolder);
    
    % handle iterator
    if exist([dataFolder '/iterator.mat'],'file') == 2
        load([dataFolder '/iterator.mat'],'iterator');
        iterator = iterator+1;
    end
    save([dataFolder '/iterator.mat'],'iterator');
    
    % create log info file
    fileID = fopen([dataFolder '/log_' num2str(iterator) '.txt'],'w');
    fprintf(fileID,'modelPath = %s\n',modelPath);
    fprintf(fileID,'dataPath = %s\n',dataPath);
    fprintf(fileID,'calibrationVersion = %s\n','TO_BE_DONE');
    fprintf(fileID,'iterator = %d\n',iterator);
    fclose(fileID);
end

%% ===================================== CALIBRATION VALIDATION ==============================
%

%% build input data before and after calibration
%
switch loadSource
    case 'cache'
        load([dataFolder '/dataCache.mat']);
    case 'dumpFile'
        % Build input data without calibration applied
        plot = false;
        data.bc = SensorsData(dataPath,'',subSamplingSize,...
            timeStart,timeStop,plot);
        [sensorsIdxListFile,sensMeasCell.bc] = data.bc.buildInputDataSet(loadJointPos,modelParams);
        
        % Build input data with calibration applied
        data.ac = SensorsData(dataPath,'',subSamplingSize,...
            timeStart,timeStop,plot,calibrationMap);
        [sensorsIdxListFile,sensMeasCell.ac] = data.ac.buildInputDataSet(loadJointPos,modelParams);
        
        % Save data in a Matlab file for faster access in further runs
        if saveToCache
            save([dataFolder '/dataCache.mat'],'data','sensorsIdxListFile','sensMeasCell');
        end
    otherwise
        disp('Unknown data source !!')
end

% iteration list
%activeAccs = modelParams.mtbSensorCodes_list{1}(cell2mat(modelParams.mtbSensorAct_list));


%% Check anysotropy of gains and offsets
%
% SensorDiagnosis.checkAccelerometersAnysotropy(...
%     data.bc,data.ac,sensorsIdxListFile,...
%     sensMeasCell.bc,sensMeasCell.ac,...
%     figsFolder,savePlot,loadJointPos);

if loadJointPos
    %% Generate predicted measurements
    %
    % create the calibration context implementing the cost function
    myCalibContext = CalibrationContextBuilder(modelPath);
    costFunction = @myCalibContext.costFunctionSigma;
    nrOfMTBAccs = length(sensorsIdxListFile);

    % init joints and sensors lists
    myCalibContext.buildSensorsNjointsIDynTreeListsForActivePart(data.bc,modelParams);
    
    % load joint positions
    myCalibContext.loadJointNsensorsDataSubset(1:data.bc.nSamples);
    
    % cost before calibration
    [initialCost,sensMeasCell.bc,sensEstCell.bc] = costFunction(0,data.bc,1:data.bc.nSamples,@lsqnonlin,false,'');
    fprintf('Mean cost before calibration (in (m.s^{-2})^2):\n');
    (initialCost'*initialCost)/(nrOfMTBAccs*data.bc.nSamples)
    
    % cost after calibration
    [finalCost,sensMeasCell.ac,sensEstCell.ac] = costFunction(0,data.ac,1:data.ac.nSamples,@lsqnonlin,false,'');
    fprintf('Mean cost after calibration (in (m.s^{-2})^2):\n');
    (finalCost'*finalCost)/(nrOfMTBAccs*data.ac.nSamples)

    %% Plot joint trajectories
    %
    SensorDiagnosis.plotJointTrajectories(data,modelParams,figsFolder,savePlot);
    
    %% Plot predicted sensor variables VS sensor sensor measurements
    %
    SensorDiagnosis.checkSensorMeasVsEst(...
        data,sensorsIdxListFile,...
        sensMeasCell.bc,sensEstCell.bc,...
        figsFolder,savePlot,'bc')
    SensorDiagnosis.checkSensorMeasVsEst(...
        data,sensorsIdxListFile,...
        sensMeasCell.ac,sensEstCell.ac,...
        figsFolder,savePlot,'ac')
end

end
