classdef LowlevTauCtrlCalibrator < Calibrator
    %LowlevTauCtrlCalibrator Holds all methods for low level joint torque control calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   low level parameters. These parameters include the PWM voltage to
    %   torque rate, the vicuous and Coulomb friction parameters.
    
    properties(Constant=true, Access=protected)
        singletonObj = LowlevTauCtrlCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'LowlevTauCtrlCalibrator';
        
        initSection@char = 'lowLevelTauCtrlCalib';
        
        calibedSensorType@char = 'LLTctrl';
    end
    
    methods(Access=protected)
        function obj = LowlevTauCtrlCalibrator()
        end
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handler to the caller
        function theInstance = instance()
            theInstance = LowlevTauCtrlCalibrator.singletonObj;
        end
    end
    
    methods(Access=public)
        run(obj,init,model,lastAcqSensorDataAccessorMap);
    end
    
    methods(Static=true, Access=protected)
        calibrateSensors(...
            dataPath,calibedParts,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
end

