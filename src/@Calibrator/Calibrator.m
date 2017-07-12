classdef Calibrator < SingletonP
    % Holds the methods for calibrating a modality of sensors or the low level parameters of an actuator type.
    %   'run' is the main scheduler, calling the acquisition, data
    %   processing and plotting fuctions, and eventually prompting the user
    %   in a given sequence.
    %   'calibrateSensors()' is the main procedure for the data processing.
    %
    
    %% Properties
    properties(Abstract=true, Constant=true, Access=public)
        task@char;
        initSection@char;
        calibedSensorType@char;
    end
    
    properties(Constant=true, Access=public)
        % acquired data accessors
        acqSensorDataAccessorMap = containers.Map('KeyType','char','ValueType','any');
        % list of figure handlers (1 per task). These handlers will hold
        % the figures handles and properties
        figuresHandlerMap = containers.Map('KeyType','char','ValueType','any');
    end
    
    %% Methods
    methods(Access=public)
        run(obj,init,model,lastAcqSensorDataAccessorMap);
    end
    
    methods(Abstract=true, Static=true, Access=protected)
        calibrateSensors(...
            dataPath,calibedParts,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
    methods(Access=protected)
        getOrAcquireData(obj,init,model,lastAcqSensorDataAccessorMap);
        
        runCalibratorOrDiagnosis(obj,init,model,calibOrDiagFuncH,calibedSensorType);
        
        jointNameList = getJointNamesFromUIidxes(obj,init,model);
    end
    
end

