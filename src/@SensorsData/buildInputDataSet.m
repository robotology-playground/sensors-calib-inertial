function [sensorsIdxListFile,sensMeasCell,time] = buildInputDataSet(...
    obj,loadJointPos,modelParams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Parsing configuration
%
for part = 1 : length(modelParams.accMeasedParts)
    % add mtx sensors (MTB or MTI-imu)
    obj.addMTXsensToData(...
        modelParams.sensorsDbase,...
        modelParams.accMeasedParts{part},...
        modelParams.activeSensorLabels{part},...
        true);
end

if loadJointPos
    % add joint measurements
    for part = 1 : length(modelParams.jointMeasedParts)
        obj.addEncSensToData(...
            modelParams.jointsDbase,...
            modelParams.jointMeasedParts{part},...
            modelParams.jointsToCalibrate.jointsDofs{part},...
            modelParams.jointsToCalibrate.ctrledJointsIdxes{part},...
            true);
    end
end

% Load data from the file and parse it
obj.loadData();


%% build input data for calibration or validation of calibration
%

% Go through 'obj.frames', and get measurement variables indexes:
sensorsIdxListFile = [];
for frame = 1:length(obj.frames)
    switch obj.type{frame}
        case {'inertialMTB','inertial'}
            sensorsIdxListFile = [sensorsIdxListFile frame];
        otherwise
    end
end

% get measurement table ys_xxx_acc [3xnSamples] from captured data,
sensMeasCell = cell(1,length(sensorsIdxListFile));
time = cell(1,length(sensorsIdxListFile));
for acc_i = 1:length(sensorsIdxListFile)
    if obj.resampleSensorMeas
        measOutput = ['ys_' obj.labels{sensorsIdxListFile(acc_i)}]; % resampled
        timeOutput = 'time';
    else
        measOutput = ['y_' obj.labels{sensorsIdxListFile(acc_i)}];  % NOT resampled
        timeOutput = ['time_' obj.labels{sensorsIdxListFile(acc_i)}];
    end
    sensMeasCell{1,acc_i} = obj.parsedParams.(measOutput)';
    time{1,acc_i} = obj.parsedParams.(timeOutput)';
end


end

