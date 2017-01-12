function [sensorsIdxListFile,sensMeasCell] = buildInputDataSet(...
    obj,loadJointPos,ModelParams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Parsing configuration
%
for part = 1 : length(ModelParams.parts)
    % add mtx sensors (MTB or MTI-imu)
    obj.addMTXsensToData(ModelParams.parts{part}, ...
        ModelParams.mtbSensorCodes_list{part}, ModelParams.mtbSensorLink_list{part}, ...
        ModelParams.mtbSensorAct_list{part}, ...
        ModelParams.mtxSensorType_list{part},true);
    
    if loadJointPos
        % add joint measurements
        obj.addEncSensToData(ModelParams.parts{part}, ...
            ModelParams.jointsToCalibrate.jointsDofs{part}, ModelParams.jointsToCalibrate.ctrledJointsIdxes{part}, ...
            true);
    end
end

% Load data from the file and parse it
obj.loadData();


%% build input data for calibration or validation of calibration
%

% Select full data subset to use on ellipsoid fitting
subsetVec_idx = linspace(1,obj.nSamples,obj.nSamples);

% Go through 'obj.frames', and get measurement variables indexes:
sensorsIdxListFile = [];
for frame = 1:length(obj.frames)
    switch obj.type{frame}
        case {'inertialMTB','inertialMTI'}
            sensorsIdxListFile = [sensorsIdxListFile frame];
        otherwise
    end
end

% get measurement table ys_xxx_acc [3xnSamples] from captured data,
sensMeasCell = cell(1,length(sensorsIdxListFile));
for acc_i = 1:length(sensorsIdxListFile)
    ys = ['ys_' obj.labels{sensorsIdxListFile(acc_i)}];
    eval(['sensMeas = obj.parsedParams.' ys '(:,subsetVec_idx);']);
    sensMeasCell{1,acc_i} = sensMeas';
end


end

