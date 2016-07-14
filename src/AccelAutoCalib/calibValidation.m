%%         Calibration Validation on several datasets
%
%
%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

% 'matFile' or 'dumpFile' mode
loadSource = 'dumpFile';
saveToCache = false;

% model and data capture file
modelPath = '../models/iCubGenova05/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova05_#3/';
dataSetNb = '';

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use 
                % the end time from log
% filtering/subsampling: the main single data bucket of (timeStop-timeStart)/10ms 
% samples is sub-sampled to 'subSamplingSize' samples for running the ellipsoid fitting.
subSamplingSize = 1000;

% define the limb from which we will calibrate all the sensors.
% Activate all the sensors of that limb.
jointsToCalibrate.parts = {'left_leg'};

%% set init parameters 'ModelParams'
%
run jointsNsensorsDefinitions;

%% ===================================== CALIBRATION VALIDATION ==============================
%

%% build input data before calibration
%

% Build input data with calibration applied
[data.bc,sensorsIdxListFile,sensMeasCell.bc] = buildInputDataSet(...
    loadSource,saveToCache,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams);

% Common result buckets
pVecList = cell(1,length(sensorsIdxListFile));
dVecList = cell(1,length(sensorsIdxListFile));
dOrientList = cell(1,length(sensorsIdxListFile));
dList = cell(1,length(sensorsIdxListFile));

%% Apply calibration and reload input data
%

% Load existing calibration
if exist('./data/calibrationMap.mat','file') == 2
    load('./data/calibrationMap.mat','calibrationMap');
end

if ~exist('calibrationMap','var')
    error('calibrationMap not found');
end

% Build input data with calibration applied
[data.ac,sensorsIdxListFile,sensMeasCell.ac] = buildInputDataSet(...
    loadSource,saveToCache,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams,calibrationMap);


%% Check distance to 9.807 sphere manifold
%

% iteration list
activeAccs = mtbSensorCodes_list{1}(cell2mat(mtbSensorAct_list));
accIter = sensorsIdxListFile;

for acc_i = accIter
    %% distance to a centered sphere (R=9.807) before calibration
    [pVec.bc,dVec.bc,dOrient.bc,d.bc] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.bc{1,acc_i}(:,1),...
        sensMeasCell.bc{1,acc_i}(:,2),...
        sensMeasCell.bc{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    %% distance to a centered sphere (R=9.807) after calibration
    [pVec.ac,dVec.ac,dOrient.ac,d.ac] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.ac{1,acc_i}(:,1),...
        sensMeasCell.ac{1,acc_i}(:,2),...
        sensMeasCell.ac{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    pVecList{1,acc_i} = pVec;
    dVecList{1,acc_i} = dVec;
    dOrientList{1,acc_i} = dOrient;
    dList{1,acc_i} = d;
    
end

%% Plot figures
%

for acc_i = accIter
    %% Plot distributions
    figure('Name',['calibration of MTB sensor ' activeAccs{acc_i}]);

    % distr of signed distances before calibration
    subplot(2,2,1);
    title('distance to a centered sphere (R=9.807) before calibration',...
        'Fontsize',16,'FontWeight','bold');
    plotNprintDistrb(dOrientList{1,acc_i}.bc);
    
    % distr of signed distances after calibration
    subplot(2,2,2);
    title('distance to a centered sphere (R=9.807) after calibration',...
        'Fontsize',16,'FontWeight','bold');
    plotNprintDistrb(dOrientList{1,acc_i}.ac);

    %% plot fitting
    subplot(2,2,3);
    title('Fitting ellipsoid before calibration','Fontsize',16,'FontWeight','bold');
    plotFittingEllipse([0 0 0]',[9.807 9.807 9.807]',eye(3,3),sensMeasCell.bc{1,acc_i});

    subplot(2,2,4);
    title('Fitting ellipsoid after calibration','Fontsize',16,'FontWeight','bold');
    plotFittingEllipse([0 0 0]',[9.807 9.807 9.807]',eye(3,3),sensMeasCell.ac{1,acc_i});
end

