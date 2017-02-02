classdef SensorDataYarpI < handle
    % Interface for accessing YARP interface.
    %   This class handles the logging of sensor data from YARP ports or
    %   just the access to and loading of previously logged data into
    %   Matlab structures.
    %   The logging is done through the YARP data dumper service:
    %   - opening/closing of the YARP ports for the set of sensors requested by the client
    %   - connection or disconnection of the ports
    %   - mapping of the logged data folder tree structure
    %   - loading of logged data into Matlab structure
    
    properties(SetAccess = protected, GetAccess = public)
        robotName = '';
        dataFolderPath = '';      % where to create /log_xxxx/dumper/ folder
        seqDataFolderPath = '';
        logInfoFileName = '';
        iteratorUpdated = false;        % true if a first log has been open
        sensorType2portNameGetter = {}; % funcs mapping sensor type to port name
        openports = {};      % current open ports with info to,from,connected
    end
    
    methods(Access = public)
        function obj = SensorDataYarpI(robotName,dataFolderPath)
            % Save parameters, robot name and data file path
            obj.robotName = robotName;
            obj.dataFolderPath = dataFolderPath;
            % build funcs mapping sensor type to port name, save func handles
            obj.buildSensType2portNgetter();
            % log info file name (used for restore/save/print of
            % 'dataLogInfoMap'
            obj.logInfoFileName = [obj.dataFolderPath '/dataLogInfo'];
        end
        
        function delete(obj)
            % disconnect and close open ports
            obj.closeLog();
            disp('dest');
        end
        
        function newLog(obj,dataLogInfo,sensorList,partsList)
            % check data log info structure fields
            if sum(~ismember({'calibApp','calibedPart','calibedSensors'},fieldnames(dataLogInfo)))>0
                error('Wrong data log info format!');
            end
            % set folder name for the data dumper and update log database
            obj.newDataSubFolderPath(dataLogInfo);
            % close any open ports and log
            obj.closeLog();
            % create ports mapping
            [newKeyList,newPortList] = cellfun(...
                @(sensor,parts) newPortEntries(sensor,parts),... % create objects and return keys
                sensorList,partsList,...                         % applied to each sensor|parts
                'UniformOutput',false);                          % return encapsulated output
            obj.openports = containers.Map([newKeyList{:}],[newPortList{:}]);
            % open ports
            obj.openPorts();
            disp('newLog');
        end
        
        function closeLog(obj)
            % disconnect all connected ports
            obj.discPorts(obj.openports);
            % close all open ports
            obj.closePorts()
            disp('closeLog');
        end
        
        function connect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = sensorsPartsLists2keys(sensorList,partsList);
            % connect ports
            obj.connPorts(keys);
            disp('conn');
        end
        
        function disconnect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = sensorsPartsLists2keys(sensorList,partsList);
            % disconnect ports
            obj.discPorts(keys);
            disp('disc');
        end
        
        function print(obj)
            %% Print the sensor data log file located in the logged data folder
            
            % Restore map from file
            dataLogInfoMap = SensorLogDatabase();
            if exist([obj.logInfoFileName '.mat'],'file') == 2
                load([obj.logInfoFileName '.mat'],'dataLogInfoMap');
            end
            fileID = fopen([obj.logInfoFileName '.txt'],'w');
            fprintf(fileID,dataLogInfoMap.toTable());
            fclose(fileID);
        end
    end
    
    methods(Access = protected)
        % only this class and derivates should build the port mapping from
        % the configuration file
        function buildSensType2portNgetter(obj)
            % init parameters from config file
            run yarpPortNameRules;
            sensorType = {...
                'joint_from','acc_from','imu_from',...
                'joint_to','acc_to','imu_to'};
            portNamingRule = {...
                eval(['@(part)' joints_port_rule_icub]),...
                eval(['@(part)' accSensors_port_rule_icub]),...
                eval(['@(part)' imuSensors_port_rule_icub]),...
                eval(['@(part)' joints_port_rule_dumper]),...
                eval(['@(part)' accSensors_port_rule_dumper]),...
                eval(['@(part)' imuSensors_port_rule_dumper])};
            obj.sensorType2portNameGetter = containers.Map(sensorType,portNamingRule);
            disp('buildPortsMapping');
        end
        
        function [newKeyList,newPortList] = newPortEntries(sensor,parts)
            % get rules for 'from' and 'to' port naming
            portNamingRuleFrom = obj.sensorType2portNameGetter([sensor '_from']);
            portNamingRuleTo = obj.sensorType2portNameGetter([sensor '_to']);
            
            % for each part in the parts list, create a port entry
            [newKeyList,newPortList] = cellfun(...
                @(part) [[sensor part],struct(...
                'from',portNamingRuleFrom(part),...
                'to',portNamingRuleTo(part),...
                'conn',false)],...
                parts,...
                'UniformOutput',false);
        end
        
        function portKeys = sensorsPartsLists2keys(sensorList,partsList)
            % DEBUG: remove acc and respective ports because they are not
            % integrated on Gazebo yet
            sensorList = sensorList(~ismember(sensorList,'acc'));
            partsList = partsList(~ismember(sensorList,'acc'));
            % END debug
            
            % generate keys for one sensor
            genKeys4oneSensor = @(sensor,parts) cellfun(...
                @(part) [sensor part],... % concatenate key '<sensor><part>'
                parts,...                 % for each part do...
                'UniformOutput',false);   % output cells {[key1] key2] ..}
            % generate keys for the whole sensor list
            portKeys = cellfun(...
                @(sensor,parts) genKeys4oneSensor(sensor,parts),... % all keys for 1 sensor
                sensorList,partsList,...             % go through all sensors n parts
                'UniformOutput',true);               % concatenate lists from interations
        end
        
        function newDataSubFolderPath(obj,dataLogInfo)
            %% update Map with log info and create folder where to store sensor data
            
            % Prepare log folders/files names
            logInfoFilePath = [obj.logInfoFileName '.mat'];
            
            % Restore map from file
            dataLogInfoMap = SensorLogDatabase();
            if exist(logInfoFilePath,'file') == 2
                load(logInfoFilePath,'dataLogInfoMap');
            end
            % Add new log entry with log info
            logFolderRelativePath = dataLogInfoMap.add(...
                obj.robotName,dataLogInfo.calibApp,...
                dataLogInfo.calibedSensors,dataLogInfo.calibedPart);
            
            % create folder
            obj.seqDataFolderPath = [obj.dataFolderPath '/' logFolderRelativePath];
            if system(['mkdir ' obj.seqDataFolderPath],'-echo')
                error('Couldn''t create log files folder!');
            end
            
            % save log info map
            save(logInfoFilePath,'dataLogInfoMap');
        end
        
        % we want to avoid several logs in the same part folder (for
        % instance "/icub/left_leg/inertialMTB","/icub/left_leg/inertialMTB_00001" etc..
        % so these methods are internally called by newLog() and closeLog()
        % which handles the switching to a new folder when required.
        function openPorts(obj)
            % open list of ports through yarpdatadumper
            for port = obj.openports.values
                if system(['yarpdatadumper --dir ' obj.dataFolderPath ...
                        ' --name ' port{:}.to ' --type bottle &'])
                    error(['couldn''t open port ' port{:} '!']);
                end
            end
            disp('open ports');
        end
        
        function closePorts(obj)
            % close all previously open ports through yarpdatadumper
            if system('pkill -9 yarpdatadumper')
                error(['couldn''t close port ' obj.openports.values{:} '!']);
            end
            % empty list of open ports
            obj.openports = {};            
            disp('close ports')
        end
        
        function connPorts(obj,portKeys)
            % return error if some ports to connect are still closed
            stillClosedPorts = ~ismember(portsKeys,obj.openports.keys);
            if sum(stillClosedPorts)>0
                error(['Trying to connect closed ports: ' portsKeys(stillClosedPorts)]);
            end
            
            % connect ports
            for key = portKeys
                % get 'from', 'to', and update 'conn' attribut
                port = obj.openports(key{:});
                % 'yarp connect <output port> <input port>
                if system(['yarp connect ' port.from ' ' port.to])
                    error(['couldn''t connect port ' port '!']);
                end
                % update 'conn' flag
                port.conn = true;
            end
            disp('connect ports');
        end
        
        function discPorts(obj,portKeys)
            % do nothing for ports already disconnected or closed
            if isempty(obj.openports)
                return;
            end
            
            % disconnect ports
            for key = portKeys
                % get 'from', 'to', and update 'conn' attribut
                port = obj.openports(key{:});
                % 'yarp disconnect <output port> <input port>
                if port.conn
                    if system(['yarp disconnect ' port.from ' ' port.to])
                        error(['couldn''t disconnect port ' port '!']);
                    end
                end
                % update 'conn' flag
                port.conn = false;
            end
            disp('disconnect ports');
        end
    end
end


