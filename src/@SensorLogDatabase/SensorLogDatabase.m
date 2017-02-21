classdef SensorLogDatabase < handle
    %Classifier of log data
    %   This class implements a database handler for all the sensor data
    %   logs, providing setters and getters of log entries through
    %   attributes like: robotname, sensor (calibrated sensor modality), part
    %   (calibrated part). The targetted information to be accessed are:
    %   calibApp (calibrator designation), seqIterator (log unique counter),
    %   calibIterator (calibrator unique counter), logPath (the actual
    %   folder path where to find the sensor data for 1 single acquisition
    %   sequence), sequence (a sequence info object constructed by
    %   MotionSequencer.seqMap2runner holding information required by the
    %   calibrator for generating the new calibration parameters (ex:
    %   JointEncodersCalibrator.calibrateSensors ), calibrationMap (current
    %   sensor calibration directly retrieved from the robot as sensor data
    %   was acquired).
    %   
    %   There are 2 levels indexing. 1rst level (container map mapAttr):
    %   - key{robotname,sensor,part} --> value{entryLvl1}
    %   
    %     note: entryLvl1 is a chronological list of seqIterator, i.e.
    %     a container map [key{calibIterator} --> value{seqIterator}]
    %     where calibIterator is the counter of a single execution of a
    %     calibrator running 1 or several motion/acquisition sequences
    %     (i.e. creating as many log entries). It might be useful in the
    %     future to correlate sensor data acquired in a short period of
    %     time, where the robot has the same configuration and the sensors
    %     the "same" behaviour/state with respect to the calibration
    %     parameters and the offsets drift.
    %
    %   2nd level (container map 'mapIter'):
    %   - key{seqIterator} --> value{entryLvl2}
    %   
    %     note: entryLvl2 is the actual targetted information, composed
    %     by the calibApp, seqIterator, calibIterator, logPath, sequence,
    %     calibrationMap.
    
    properties(SetAccess = protected, GetAccess = protected)
        seqIterator = 0;   % counter as a unique identifyer of the log entry
        calibIterator = 0; % counter as a unique identifyer of a calibrator iteration
        schedCalibIterator = []; % scheduled next counter value, triggered by a calibrator
        mapAttr = {}; % map using key = [robotName '.' sensor '.' calibedPart]
        key2RSP = {};
        mapIter = {}; % map using key = seqIterator
        logInfoFileName = '';
    end
    
    methods
        function obj = SensorLogDatabase(dataFolderPath)
            % log info file name (used for restore/save of
            % 'dataLogInfoMap'
            obj.logInfoFileName = [dataFolderPath '/dataLogInfo'];
            
            % Eventually restore map from file
            if exist([obj.logInfoFileName '.mat'],'file') == 2
                load([obj.logInfoFileName '.mat'],'dataLogInfoMap');
                obj = dataLogInfoMap;
            else
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
            
            % For safety, rewrite some parameters
            obj.logInfoFileName = [dataFolderPath '/dataLogInfo'];
            obj.schedCalibIterator = [];
        end
        
        function scheduleNewAcquisition(obj)
            % A new acquisition session is triggered by a calibrator and
            % can run several motion/acquisition sequences.
            obj.schedCalibIterator = obj.calibIterator+1;
        end
        
        function logRelativePath = add(obj,robotName,dataLogInfo)
            % check data log info structure fields and sensor/parts lists
            if sum(~ismember(...
                    {'calibApp','calibedSensorList','calibedPartsList','sequence'},...
                    fieldnames(dataLogInfo)))>0
                warning('Wrong data log info format. Log info not registered!');
                return;
            end
            
            % Update the calibrator iteration with the new scheduled value
            if ~isempty(obj.schedCalibIterator)
                obj.calibIterator = obj.schedCalibIterator;
            end
            % Update the seqIterator. for all the sensors, we add the same
            % only log entry
            obj.seqIterator = obj.seqIterator+1;
            
            % define the keys pointing to a log or list of logs (several
            % logs at different times of the same robot|sensorType|part
            
            % key generation for all parts
            [logKeys,keyExpanders] = cellfun(...
                @(sensor,parts) obj.genKey1Sensor(robotName,sensor,parts),...  %2-generate sub-list of keys for that part
                dataLogInfo.calibedSensorList,dataLogInfo.calibedPartsList,... % 1-for each part with associated sensors
                'UniformOutput',false);                                        % 3-concatenate key sub-lists
            logKeys = [logKeys{:}];
            keyExpanders = [keyExpanders{:}];
            
            % add key expanders
            obj.key2RSP = [obj.key2RSP;containers.Map(logKeys,keyExpanders)];
            
            % Update entry level 1 for each requested key. If key doesn't
            % exist yet, create a new entry (empty map container)
            for ckey = logKeys
                key = ckey{:};
                if ~isKey(obj.mapAttr,key)
                    obj.mapAttr(key) = containers.Map('KeyType','int32','ValueType','any');
                end
                entryLvl1 = obj.mapAttr(key);
                entryLvl1(obj.calibIterator) = obj.seqIterator;
            end
            
            % define log entry level 2
            logPath = [...
                robotName '.' dataLogInfo.calibApp ...
                '#' num2str(obj.calibIterator) '.seq#' num2str(obj.seqIterator)];
            
            newEntryLvl2 = struct(...
                'calibApp',dataLogInfo.calibApp,...
                'calibIterator',obj.calibIterator,...
                'seqIterator',obj.seqIterator,...
                'sequence',dataLogInfo.sequence,...
                'logPath',logPath);
            
            % Add log entry to the map of iterators
            obj.mapIter(obj.seqIterator) = newEntryLvl2;
            
            % return the log relative path
            logRelativePath = logPath;
            
            % save log info to a file
            dataLogInfoMap = obj;
            save([obj.logInfoFileName '.mat'],'dataLogInfoMap');
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
            
            str = ['seqIterator = ' obj.seqIterator '\n\n'];
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

