classdef SensorLogDatabase < handle
    %Classifier of log data
    %   This class implements a database handler for all the sensor data
    %   logs, providing setters and getters of log entries through
    %   attributes like: robotname, calibrated sensor modality, calibrated
    %   part, log tag (iterator).
    
    properties(SetAccess = protected, GetAccess = protected)
        iterator;
        mapAttr = {}; % map using key = [robotName '.' sensor '.' calibedPart]
        key2RSP = {};
        mapIter = {}; % map using key = iterator
    end
    
    methods
        function obj = SensorLogDatabase()
            % counter as a unique identifyer of the log entry 
            obj.iterator = 0;
            % mapping keys to log entries (folder paths)
            obj.mapAttr = containers.Map('KeyType','char','ValueType','any');
            % expanding the key to the attributes used to build the key
            % (R:robotName; S:sensor; P:part). We choosed here a map to
            % have the extraction of the attributes independant from the
            % way the key is built from them. We call each map element an
            % expander.
            obj.key2RSP = containers.Map('KeyType','char','ValueType','any');
            
            obj.mapIter = containers.Map('KeyType','int32','ValueType','any');
        end
        
        function logRelativePath = add(obj,robotName,calibApp,calibedSensorList,calibedPartsList)
            % Update the iterator. for all the sensors, we add the same
            % only log entry
            obj.iterator = obj.iterator+1;
            
            % define the keys pointing to a log or list of logs (several
            % logs at different times of the same robot|sensorType|part
            
            % key generation for all parts
            [logKeys,keyExpanders] = cellfun(...
                @(sensor,parts) obj.genKey1Sensor(robotName,sensor,parts),... %2-generate sub-list of keys for that part
                calibedSensorList,calibedPartsList,...  % 1-for each part with associated sensors
                'UniformOutput',false);                 % 3-concatenate key sub-lists
            logKeys = [logKeys{:}];
            keyExpanders = [keyExpanders{:}];
            
            % add key expanders
            obj.key2RSP = [obj.key2RSP;containers.Map(logKeys,keyExpanders)];
            
            % define log entry
            logPath = [robotName '.' calibApp '#' num2str(obj.iterator)];
            newEntry = struct('calibApp',calibApp,'iterator',obj.iterator,'logPath',logPath);
            
            % Add log entry to the same current map pointed by all the
            % keys 'logKeys'
            for ckey = logKeys
                key = ckey{:};
                if ~isKey(obj.mapAttr,key)
                    obj.mapAttr(key) = containers.Map('KeyType','int32','ValueType','any');
                end
                entryMap = obj.mapAttr(key);
                entryMap(obj.iterator) = newEntry;
            end
            
            % Add log entry to the map of iterators
            obj.mapIter(obj.iterator) = {newEntry};
            
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
%             % create cell array expander
%             charConv = @(aType) obj.converterKey2RSP(aType);
%             converter = Converters('V','char',charConv);
%             % convert mapAttr to cell array
%             AttrAscellArray = converter.recursiveAny2cellArray(obj.mapAttr);
            
            str = ['iterator = ' obj.iterator '\n\n'];
%             str = [str obj.toTable() '\n'];
        end
    end
    
    methods(Access = protected)
        function aKey2struct = converterKey2RSP(obj,aKey)
            if isKey(obj.key2RSP,aKey)
                aKey2struct = obj.key2RSP(aKey);
            else
                aKey2struct = aKey;
            end
        end
    end
    
    methods(Static = true)
        function [keys,fields] = genKey1Sensor(robotName,calibedSensor,calibedParts)
            % key generation through sensor list for 1 part
            [keys,fields] = cellfun(...
                @(part) deal(...
                [robotName '.' calibedSensor '.' part],...  % 2-concatenate key string
                struct(...
                'robotName',robotName,'calibedSensor',calibedSensor,...
                'calibedPart',part)),...            % 3-define structure expanding the key
                calibedParts,...                    % 1-for each sensor type
                'UniformOutput',false);             % 4-and put output in a cell
        end
    end
end

