classdef SensorLogDatabase < handle
    %Classifier of log data
    %   This class implements a database handler for all the sensor data
    %   logs, providing setters and getters of log entries through
    %   attributes like: robotname, calibrated sensor modality, calibrated
    %   part, log tag (iterator).
    
    properties(SetAccess = protected, GetAccess = protected)
        iterator;
        map = {};
        key2RSP = {};
    end
    
    methods
        function obj = SensorLogDatabase()
            % counter as a unique identifyer of the log entry 
            obj.iterator = 0;
            % mapping keys to log entries (folder paths)
            obj.map = containers.Map('KeyType','char','ValueType','any');
            % expanding the key to the attributes used to build the key
            % (R:robotName; S:sensor; P:part). We choosed here a map to
            % have the extraction of the attributes independant from the
            % way the key is built from them. We call each map element an
            % expander.
            obj.key2RSP = containers.Map('KeyType','char','ValueType','any');
        end
        
        function logRelativePath = add(obj,robotName,calibApp,calibedPartList,calibedSensorsList)
            % Update the iterator. for all the sensors, we add the same
            % only log entry
            obj.iterator = obj.iterator+1;
            
            % define the keys pointing to a log or list of logs (several
            % logs at different times of te same robot|sensorType|part
            [logKeys,keyExpanders] = cellfun(...
                @(sensor) deal(...
                [robotName '.' sensor '.' calibedPart],...  % 2-concatenate key string
                struct(...
                'robotName',robotName,'calibedSensor',sensor,...
                'calibedPart',calibedPart)),...             % 3-define structure expanding the key
                calibedSensors,...                  % 1-for each sensor type
                'UniformOutput',false);             % 4-and put output in a cell
            
            % add key expanders
            obj.key2RSP = [obj.key2RSP;containers.Map(logKeys,keyExpanders)];
            
            % define log entry
            logPath = [robotName '.' calibApp '.' calibedPart '#' num2str(obj.iterator)];
            newEntry = struct('calibApp',calibApp,'iterator',obj.iterator,'logPath',logPath);
            
            % Add log entry to the same current map pointed by all the
            % keys 'logKeys'
            if ~isKey(logKeys{1})
                obj.map(logKeys{1}) = containers.Map('KeyType','int32','ValueType','any');
            end
            entryMap = obj.map(logKeys{1});
            entryMap(obj.iterator) = newEntry;
            
            % return the log relative path
            logRelativePath = logPath;
        end
        
        function logInfo = getLast1(obj,robotName,calibedSensor)
            logInfo = {};
        end
        
        function logInfo = getLast2(obj,robotName,calibedSensor,calibedPartList)
            logInfo = {};
        end
        
        function logInfo = getLast3(obj,iterator)
            logInfo = {};
        end
        
        function str = toString(obj)
            str = ['iterator = ' obj.iterator '\n\n'];
            str = [str obj.toTable() '\n'];
        end
        
        function table = toTable(obj)
            mapAsCell  = [obj.map.keys;obj.map.values];
            table = cell2table(mapAsCell);
        end
    end
end

