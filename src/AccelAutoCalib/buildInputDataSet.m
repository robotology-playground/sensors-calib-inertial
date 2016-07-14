function [data,sensorsIdxListFile,sensMeasCell] = buildInputDataSet(...
    loadSource,saveToCache,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams,calibrationMap)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Parsing configuration
%
switch loadSource
    case 'matFile'
        load './data/data.mat';
    case 'dumpFile'
        % build sensor data parser ('inputFilePath',nbSamples,tInit,tEnd,plot--true/false)
        if exist('calibrationMap','var')
            data = SensorsData(dataPath,dataSetNb,subSamplingSize,...
                timeStart,timeStop,false,calibrationMap);
        else
            data = SensorsData(dataPath,dataSetNb,subSamplingSize,...
                timeStart,timeStop,false);
        end            
        
        for part = 1 : length(ModelParams.jointsToCalibrate.parts)
            % Number of sensors for current part are:
            nrOfMTBAccs = length(ModelParams.mtbSensorLink_list{part});
            
            % add mtx sensors (MTB or MTI-imu)
            data.addMTXsensToData(ModelParams.jointsToCalibrate.parts{part}, 1:nrOfMTBAccs, ...
                ModelParams.mtbSensorCodes_list{part}, ModelParams.mtbSensorLink_list{part}, ...
                ModelParams.mtbSensorAct_list{part}, ...
                ModelParams.mtxSensorType_list{part},true);
        end
        
        % Load data from the file and parse it
        data.loadData();
        
        % Save data in a Matlab file for faster access in further runs
        if saveToCache
            save('./data/data.mat','data');
        end
    otherwise
        disp('Unknown data source !!')
end

%% build input data for calibration or validation of calibration
%

% Select full data subset to use on ellipsoid fitting
subsetVec_idx = linspace(1,data.nSamples,data.nSamples);

% Go through 'data.frames', and get sensor measurements :
sensorsIdxListFile = [];
for frame = 1:length(data.frames)
    switch data.type{frame}
        case {'inertialMTB','inertialMTI'}
            sensorsIdxListFile = [sensorsIdxListFile frame];
        otherwise
    end
end

% get measurement table ys_xxx_acc [3xnSamples] from captured data,
sensMeasCell = cell(1,length(sensorsIdxListFile));
for acc_i = 1:length(sensorsIdxListFile)
    ys = ['ys_' data.labels{sensorsIdxListFile(acc_i)}];
    eval(['sensMeas = data.parsedParams.' ys '(:,subsetVec_idx);']);
    sensMeasCell{1,acc_i} = sensMeas';
end


end

