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
        dataLogInfoMap = [];
        sensorType2portNameGetter = {}; % funcs mapping sensor type to port name
        openports = containers.Map();      % current open ports with info to,from,connected
        uninitYarpAtDelete = false;
    end
    
    methods(Access = public)
        function obj = SensorDataYarpI(robotName,dataFolderPath)
            % Create YARP Network device, for initializing YARP classes for
            % communication, if not yet initialized
            if ~yarp.Network.initialized
                yarp.Network.init();
                obj.uninitYarpAtDelete = true;
            end
            
            % Save parameters, robot name and data file path
            obj.robotName = robotName;
            obj.dataFolderPath = dataFolderPath;
            % build funcs mapping sensor type to port name, save func handles
            obj.buildSensType2portNgetter();
            % map for storing sensor data log context information
            obj.dataLogInfoMap = SensorLogDatabase(obj.dataFolderPath);
        end
        
        function delete(obj)
            % disconnect and close open ports
            obj.closeLog();
            if obj.uninitYarpAtDelete
                yarp.Network.fini();
            end
        end
        
        function scheduleNewAcquisition(obj)
            obj.dataLogInfoMap.scheduleNewAcquisition();
        end
        
        function logFolderRelativePath = newLog(obj,dataLogInfo,sensorList,partsList)
            % close any open ports and log
            obj.closeLog();
            
            % check sensor/parts lists
            if isempty(sensorList) || isempty(partsList)
                error('List of parts or list of sensors is empty!');
            end
            
            % set folder name for the data dumper and update log database
            logFolderRelativePath = obj.newDataSubFolderPath(dataLogInfo);
            
            % create ports mapping (needs the folder name for the data
            % dumper because it stores the subfolders names)
            [newKeyList,newPortList] = cellfun(...
                @(sensor,parts) obj.newPortEntries(sensor,parts),... % create objects and return keys
                sensorList,partsList,...                         % applied to each sensor|parts
                'UniformOutput',false);                          % return encapsulated output
            obj.openports = containers.Map([newKeyList{:}],[newPortList{:}]);
        end
        
        function closeLog(obj)
            if ~isempty(obj.openports)
                % Disconnect and close all previously open ports
                % For each key entry, erase respective connection
                % configuration. The method handles redundant handlers.
                for key = obj.openports.keys
                    connectionSetup = obj.openports(key{1});
                    % Erase pointed connection configuration
                    % - disconnects any connected port
                    % - stops the yarpdatadumper instance if it exists and
                    % closes the respective dumper port
                    % - removes the tracking of the connection from the
                    % common connection list
                    connectionSetup.remove();
                    % Remove the connection handler (pointer) from the map
                    % (pair {key/handler}. A given connection will actually
                    % be deleted if all pointing handlers have been
                    % deleted.
                    obj.openports.remove(key{1});
                end
            end
        end
        
        function connect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = obj.sensorsPartsLists2keys(sensorList,partsList);
            % connect ports
            obj.connPorts(keys);
        end
        
        function disconnect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = obj.sensorsPartsLists2keys(sensorList,partsList);
            % disconnect ports
            obj.discPorts(keys);
        end
        
        function print(obj)
            % Print the sensor data log file located in the logged data folder
            fileID = fopen('dataLogInfoMap.txt','w');
            fprintf(fileID,'%s',obj.dataLogInfoMap.toString());
            fclose(fileID);
        end
    end
    
    %%===============  PROTECTED METHODS  ================================
    
    methods(Access = protected)
        % only this class and derivates should build the port mapping from
        % the configuration file
        function buildSensType2portNgetter(obj)
            % init parameters from config file
            run yarpPortNameRules;
            sensorType = {...
                'joint_from','acc_from','gyro8_from','gyro9_from','imu_from','xsens_from','fts_from','jtorq_from,'...
                'joint_to','acc_to','gyro8_to','gyro9_to','imu_to','xsens_to','fts_to','jtorq_to',...
                'joint_path','acc_path','gyro8_path','gyro9_path','imu_path','xsens_path','fts_path','jtorq_path'};
            portNamingRule = {...
                eval(['@(robotname,part)' joints_port_rule_icub]),...
                eval(['@(robotname,part)' accSensors_port_rule_icub]),...
                eval(['@(robotname,part)' gyro8Sensors_port_rule_icub]),...
                eval(['@(robotname,part)' gyro9Sensors_port_rule_icub]),...
                eval(['@(robotname,part)' imuSensors_port_rule_icub]),...
                eval(['@(robotname,part)' xsensSensors_port_rule_icub]),...
                eval(['@(robotname,part)' FTSensors_port_rule_icub]),...
                eval(['@(robotname,part)' joints_port_rule_icub]),...
                eval(['@(robotname,part)' joints_port_rule_dumper]),...
                eval(['@(robotname,part)' accSensors_port_rule_dumper]),...
                eval(['@(robotname,part)' gyro8Sensors_port_rule_dumper]),...
                eval(['@(robotname,part)' gyro9Sensors_port_rule_dumper]),...
                eval(['@(robotname,part)' imuSensors_port_rule_dumper]),...
                eval(['@(robotname,part)' xsensSensors_port_rule_dumper]),...
                eval(['@(robotname,part)' FTSensors_port_rule_dumper]),...
                eval(['@(robotname,part)' joints_port_rule_dumper]),...
                eval(['@(datapath,part)' joints_folder_rule_dumper]),...
                eval(['@(datapath,part)' accSensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' gyro8Sensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' gyro9Sensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' imuSensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' xsensSensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' FTSensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' joints_folder_rule_dumper])};
            obj.sensorType2portNameGetter = containers.Map(sensorType,portNamingRule);
        end
        
        function [newKeyList,newPortList] = newPortEntries(obj,sensor,parts)
            %% each port(yarp link) entry is a structure with following fields:
            %  - from: source port
            %  - to  : sink port
            %  - path: path to the stored sensor data (*)
            %  - conn: true if connected, false if not
            %  - pid : 'yarpdatadumper' process PID that open the port
            % Note(*): When this method is called, the data folder root
            % 'dataFolderPath' has already been set.
            
            % get rules for 'from' and 'to' port naming
            portNamingRuleFrom = obj.sensorType2portNameGetter([sensor '_from']);
            portNamingRuleTo = obj.sensorType2portNameGetter([sensor '_to']);
            portNamingRulePath = obj.sensorType2portNameGetter([sensor '_path']);
            
            switch sensor
                case 'acc'
                    convert = containers.Map(...
                        {'left_arm','right_arm','left_leg','right_leg','torso','head'},...
                        {'left_hand','right_hand','left_leg','right_leg','torso','head'});
                otherwise
                    convert = @(part) part;
            end
            
            % for each part in the parts list, create a port entry
            [newKeyList,newPortList] = cellfun(...
                @(part) deal([sensor part],...          % 2-create a key
                Connection(...                          % 3-port naming rules for...
                portNamingRuleFrom(obj.robotName,convert(part)),... % 'from': source port
                portNamingRuleTo(obj.robotName,part),...            % 'to'  : sink port
                portNamingRulePath(obj.seqDataFolderPath,part))),...  % 'path': to the stored sensor data
                parts,...                               % 1-for each part...
                'UniformOutput',false);                 % 5-don't concatenate lists from iterations
        end
        
        function logFolderRelativePath = newDataSubFolderPath(obj,dataLogInfo)
            %% update Map with log info and create folder where to store sensor data
            
            % Add new log entry with log info (will be associated to a new
            % unique iterator in 'dataLogInfoMap')
            logFolderRelativePath = obj.dataLogInfoMap.add(obj.robotName,dataLogInfo);
            
            % create folder. We use system() instead of the built'in
            % function because the answer is more accurate: 'false' if the
            % folder already exists.
            obj.seqDataFolderPath = [obj.dataFolderPath '/' logFolderRelativePath];
            if system(['mkdir ' obj.seqDataFolderPath],'-echo')
                error('Couldn''t create log files folder!');
            end
        end
        
        function connPorts(obj,portKeys)
            % return error if some ports to connect are still closed or no
            % connection preconfiguration exists
            stillClosedPorts = ~isKey(obj.openports,portKeys);
            if sum(stillClosedPorts)>0
                error(['Trying to activate unconfigured connections to ports: ' portsKeys(stillClosedPorts)]);
            end
            
            % connect ports
            for connectionSetup = obj.openports.values(portKeys)
                connectionSetup{1}.connect();
            end
        end
        
        function discPorts(obj,portKeys)
            % do nothing for ports already closed
            stillOpenPorts = isKey(obj.openports,portKeys);
            
            % disconnect ports
            for connectionSetup = obj.openports.values(portKeys(stillOpenPorts))
                connectionSetup{1}.disconnect();
            end
        end
    end
    
    %% ===============  STATIC PROTECTED METHODS  ======================
    
    methods(Static = true,Access = protected)
        function portKeys = sensorsPartsLists2keys(sensorList,partsList)
            % generate keys for one sensor
            genKeys4oneSensor = @(sensor,parts) cellfun(...
                @(part) [sensor part],... % concatenate key '<sensor><part>'
                parts,...                 % for each part do...
                'UniformOutput',false);   % output cells {[key1] key2] ..}
            % generate keys for the whole sensor list
            portKeys = cellfun(...
                @(sensor,parts) genKeys4oneSensor(sensor,parts),... % all keys for 1 sensor
                sensorList,partsList,...             % go through all sensors n parts
                'UniformOutput',false);              % cannot concatenate lists from iterations
            portKeys = [portKeys{:}];                % concatenate them here!
        end
    end
    
    %% ===============  STATIC METHODS  ================================

    methods(Static = true,Access = public)
        [ok] = waitPortOpen(port,timeout);
        
        function clean()
            % clean yarp ports
            system('yarp clean');
        end
    end
end


