function plotTrainingData(obj,path,sensors,parts,model,taskSpec)
% This function plots the acquired data for the friction or ktau calibration
%   Detailed explanation goes here

% Get calibration map
calibrationMap = model.calibrationMap;

% Unwrap task specific parameters, defines:
% - frictionOrKtau       -> = 'friction' for friction calibration
%                           = 'ktau' for ktau calibration
% - jointMotorGroupLabel -> label for retrieving the currently calibrated
%                           joint/motor group info. Refer to jointsDbase
%                           class interface.
% - savePlot
% 
% - exportPlot
% 
% a joint/motor group info is formatted as follows:
% group.coupledJoints : ordered list of joint names (size 1 or n)
% group.coupledMotors : ordered list of MotorFriction object handles (same size)
% group.T             : 3x3 matrix or integer 1
% 
Init.unWrap(taskSpecificParams);

%% build input data for calibration
%
% build sensor data parser
jtMotGrpInfo = model.jointsDbase.getJmGrpInfo(jointMotorGroupLabel);

dataLoadingParams = LowlevTauCtrlCalibrator.buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    jtMotGrpInfo.coupledJoints);

plot = false; loadJointPos = true;
data = SensorsData(dataPath,'',obj.subSamplingSize,...
    obj.timeStart,obj.timeStop,plot,calibrationMap);
data.buildInputDataSet(loadJointPos,dataLoadingParams);

%===========================
% Implement plotting here

%===========================

end

