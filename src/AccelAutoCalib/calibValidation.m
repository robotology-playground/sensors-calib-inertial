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
ModelParams = jointsNsensorsDefinitions(parts,jointsIdxes,jointsDq0,mtbSensorAct);

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
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' figsFolder],'-echo')
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' dataFolder],'-echo')
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

% Build input data without calibration applied
[data.bc,sensorsIdxListFile,sensMeasCell.bc] = buildInputDataSet(...
    loadSource,saveToCache,loadJointPos,...
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
    loadSource,saveToCache,false,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams,calibrationMap);

% iteration list
activeAccs = ModelParams.mtbSensorCodes_list{1}(cell2mat(ModelParams.mtbSensorAct_list));


%% Check anysotropy of gains and offsets
%
checkAccelerometersAnysotropy(...
    data,sensorsIdxListFile,activeAccs,sensMeasCell,subSamplingSize,...
    figsFolder,logTest,loadJointPos);

%% Plot joint trajectories
%
if loadJointPos
    plotJointTrajectories(data,ModelParams,figsFolder,logTest);
end

%% Log all data
if logTest
    save([dataFolder '/log_' num2str(iterator) '_All.mat']);
end 

