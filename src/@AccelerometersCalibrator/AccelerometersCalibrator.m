classdef AccelerometersCalibrator < Calibrator
    %AccelerometersCalibrator Holds all methods for calibrating the accelerometers.
    %   'calibrateSensors()' is the main procedure.
    
    properties(Constant=true, Access=protected)
        singletonObj = AccelerometersCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'accelerometersCalibrator';
        
        initSection@char = 'accelerometersCalib';
        
        calibedSensorType@char = 'acc';
    end
    
    methods(Access=protected)
        function obj = AccelerometersCalibrator()
        end
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handler to the caller
        function theInstance = instance()
            theInstance = AccelerometersCalibrator.singletonObj;
        end
    end
    
    methods(Static=true, Access=protected)
        calibrateSensors(...
            dataPath,~,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
end
