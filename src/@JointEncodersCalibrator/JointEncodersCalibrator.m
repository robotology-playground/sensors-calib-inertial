classdef JointEncodersCalibrator
    %JointEncodersCalibrator Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static = true, Access = public)
        newCalibrationMap = calibrateSensors(...
            modelPath,calibrationMap,...
            calibedParts,calibedJointsIdxes,dataPath);
    end
    
    methods(Static = true, Access = protected)
        [optimFunction,options] = getOptimConfig();
    end
    
end

