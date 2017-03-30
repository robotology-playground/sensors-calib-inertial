classdef JointEncodersCalibrator
    %JointEncodersCalibrator Holds all methods for joint encoders calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   joint encoders. 'getOptimConfig()' configures the lsqnonlin non
    %   linear solver for the least squares optimization run by the main
    %   procedure.
    
    methods(Static = true, Access = public)
        calibrateSensors(...
            modelPath,calibrationMap,...
            calibedParts,taskSpecificParams,dataPath,...
            measedSensorList,measedPartsList);
    end
    
    methods(Static = true, Access = protected)
        [optimFunction,options] = getOptimConfig();
        
        plotJointsOffsets(mean_optDq,std_optDq);
    end
    
end

