classdef JointEncodersCalibrator
    %JointEncodersCalibrator Holds all methods for joint encoders calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   joint encoders. 'getOptimConfig()' configures the lsqnonlin non
    %   linear solver for the least squares optimization run by the main
    %   procedure.
    
    methods(Static = true, Access = public)
        newCalibrationMap = calibrateSensors(...
            modelPath,calibrationMap,...
            calibedParts,calibedJointsIdxes,dataPath);
    end
    
    methods(Static = true, Access = protected)
        [optimFunction,options] = getOptimConfig();
    end
    
end

