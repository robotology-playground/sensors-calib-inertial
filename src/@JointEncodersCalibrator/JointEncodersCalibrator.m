classdef JointEncodersCalibrator < Calibrator
    %JointEncodersCalibrator Holds all methods for joint encoders calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   joint encoders. 'getOptimConfig()' configures the lsqnonlin non
    %   linear solver for the least squares optimization run by the main
    %   procedure.
    
    properties(Constant=true, Access=protected)
        singletonObj = JointEncodersCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'jointEncodersCalibrator';
        
        initSection@char = 'jointEncodersCalib';
        
        calibedSensorType@char = 'joint';
    end
    
    methods(Access=protected)
        function obj = JointEncodersCalibrator()
        end
        
        calibrateSensors(obj,...
            dataPath,calibedParts,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handler to the caller
        function theInstance = instance()
            theInstance = JointEncodersCalibrator.singletonObj;
        end
    end
    
    methods(Static=true, Access=protected)
        [optimFunction,options] = getOptimConfig();
        
        plotJointsOffsets(mean_optDq,std_optDq);
    end
    
end

