classdef SensorLogDatabase < handle
    %Classifier of log data
    %   This class implements a database handler for all the sensor data
    %   logs, providing setters and getters of log entries through
    %   attributes like: robotname, calibrated sensor modality, calibrated
    %   part, log tag (iterator).
    
    properties(SetAccess = protected, GetAccess = protected)
        iterator = 0;
        map = {};
    end
    
    methods
        function obj = SensorLogDatabase()
            obj.map = containers.Map('KeyType','char','ValueType','any');
        end
        
        function logRelativePath = add(obj,robotName,calibApp,calibedSensor,calibedPart)
        end
        
        function logInfo = getLast1(obj,robotName,calibedSensor)
        end
        
        function logInfo = getLast2(obj,robotName,calibedSensor,calibedPartList)
        end
        
        function logInfo = getLast3(obj,iterator)
        end
        
        function str = toString(obj)
        end
        
        function table = toTable(obj)
        end
    end
end

