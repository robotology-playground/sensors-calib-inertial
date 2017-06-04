function dataLoadingParams = buildDataLoadingParams(...
    model,measedSensorList,measedPartsList,...
    calibedJointOrderedList)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

parts = [measedPartsList{ismember(measedSensorList,'joint')}];

for i = 1:length(parts)
    jointList = obj.jointsDbase.getJointNames(parts{i}); % this joints list is ordered as the data logged by the YARP data dumper
    jointsToCalibrate.jointsDofs{i} = model.jointsDbase.getTotalJointDoF(jointList);
    [~,jointsToCalibrate.ctrledJointsIdxes{i}] = ismember(calibedJointOrderedList,jointList);
end

dataLoadingParams.accMeasedParts = {};
dataLoadingParams.jointMeasedParts = parts;
dataLoadingParams.jointsDbase = model.jointsDbase;
dataLoadingParams.jointsToCalibrate = jointsToCalibrate;

end
