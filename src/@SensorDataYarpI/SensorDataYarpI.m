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
            % close any open ports and log
            obj.closeLog();
            
            % check data log info structure fields and sensor/parts lists
            if sum(~ismember(...
                    {'calibApp','calibedSensorList','calibedPartsList'},...
                    fieldnames(dataLogInfo)))>0
                error('Wrong data log info format!');
            end
            if isempty(sensorList) || isempty(partsList)
                error('List of parts or list of sensors is empty!');
            end
            
            % set folder name for the data dumper and update log database
            obj.newDataSubFolderPath(dataLogInfo);
            
            % create ports mapping (needs the folder name for the data
            % dumper because it stores the subfolders names)
            [newKeyList,newPortList] = cellfun(...
                @(sensor,parts) obj.newPortEntries(sensor,parts),... % create objects and return keys
                sensorList,partsList,...                         % applied to each sensor|parts
                'UniformOutput',false);                          % return encapsulated output
            obj.openports = containers.Map([newKeyList{:}],[newPortList{:}]);
            
            % open ports
            obj.openPorts();
            disp('newLog');
        end
        
        function closeLog(obj)
            % if there are any open ports
            if ~isempty(obj.openports)
                obj.discPorts(obj.openports.keys); % disconnect them
                obj.closePorts();                  % close them
            end
            disp('closeLog');
        end
        
        function connect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = obj.sensorsPartsLists2keys(sensorList,partsList);
            % connect ports
            obj.connPorts(keys);
            disp('conn');
        end
        
        function disconnect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = obj.sensorsPartsLists2keys(sensorList,partsList);
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
            fprintf(fileID,'%s',dataLogInfoMap.toString());
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
                'joint_from','acc_from','imu_from',...
                'joint_to','acc_to','imu_to',...
                'joint_path','acc_path','imu_path'};
            portNamingRule = {...
                eval(['@(robotname,part)' joints_port_rule_icub]),...
                eval(['@(robotname,part)' accSensors_port_rule_icub]),...
                eval(['@(robotname,part)' imuSensors_port_rule_icub]),...
                eval(['@(robotname,part)' joints_port_rule_dumper]),...
                eval(['@(robotname,part)' accSensors_port_rule_dumper]),...
                eval(['@(robotname,part)' imuSensors_port_rule_dumper]),...
                eval(['@(datapath,part)' joints_folder_rule_dumper]),...
                eval(['@(datapath,part)' accSensors_folder_rule_dumper]),...
                eval(['@(datapath,part)' imuSensors_folder_rule_dumper])};
            obj.sensorType2portNameGetter = containers.Map(sensorType,portNamingRule);
            disp('buildPortsMapping');
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
            
            % for each part in the parts list, create a port entry
            [newKeyList,newPortList] = cellfun(...
                @(part) deal([sensor part],...          % 2-create a key
                struct(...                              % 3-port naming rules for...
                'from',portNamingRuleFrom(obj.robotName,part),...         % source port
                'to',portNamingRuleTo(obj.robotName,part),...             % sink port
                'path',portNamingRulePath(obj.seqDataFolderPath,part),... % path to the stored sensor data
                'conn',false,...                        % Yarp link connection state
                'pid',[])),...                          % process PID that open the port
                parts,...                               % 1-for each part...
                'UniformOutput',false);                 % 5-don't concatenate lists from iterations
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
                dataLogInfo.calibedSensorList,dataLogInfo.calibedPartsList);
            
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
            for key = obj.openports.keys
                % get port to open
                port = obj.openports(key{:});
                % run datadumper and get process PID
                system('echo $!'); % flush output of previous system commands
                [status,pid]=system(...
                    ['yarpdatadumper ' ...    % run data dumper
                    '--dir ' port.path ...    % set output folder
                    ' --name ' port.to ' --type bottle ' ... % yarp port, data type
                    '&> /dev/null & ' ...     % redirect all output to garbage and run process on backgroung
                    'echo $!']);              % get process PID
                if status
                    error(['couldn''t open port ' port.to '!']);
                end
                port.pid = str2double(pid); % convert and store PID (removes trail spaces)
                % double check that PID is attached to a yarpdatadumper process
                if ~obj.doesPIDmatchDatadumper(port.pid)
                    error('Wrong yarpdatadumper PID!');
                end
                obj.openports(key{:}) = port;
            end
            disp('open ports');
        end
        
        function closePorts(obj)
            % close all previously open ports through yarpdatadumper
            for key = obj.openports.keys
                % get yarpdatadumper process PID and close port
                port = obj.openports(key{:});
                if system(['kill ' num2str(port.pid)])
                    error(['couldn''t close port ' port.to '!']);
                end
            end
            % empty list of open ports
            obj.openports = {};            
            disp('close ports')
        end
        
        function connPorts(obj,portKeys)
            % return error if some ports to connect are still closed
            stillClosedPorts = ~isKey(obj.openports,portKeys);
            if sum(stillClosedPorts)>0
                error(['Trying to connect closed ports: ' portsKeys(stillClosedPorts)]);
            end
            
            % connect ports
            for key = portKeys
                % get 'from', 'to', and update 'conn' attribut
                port = obj.openports(key{:});
                if ~port.conn   % if port is not connected
                    % 'yarp connect <output port> <input port>
                    if system(['yarp connect ' port.from ' ' port.to])
                        error(['couldn''t connect port ' port.to '!']);
                    end
                    % update 'conn' flag
                    port.conn = true;
                end
            end
            disp('connect ports');
        end
        
        function discPorts(obj,portKeys)
            % do nothing for ports already closed
            stillOpenPorts = isKey(obj.openports,portKeys);
            
            % disconnect ports
            for key = portKeys(stillOpenPorts)
                % get 'from', 'to', and update 'conn' attribut
                port = obj.openports(key{:});
                % 'yarp disconnect <output port> <input port>
                if port.conn      % if port is connected
                    if system(['yarp disconnect ' port.from ' ' port.to])
                        error(['couldn''t disconnect port ' port.to '!']);
                    end
                    % update 'conn' flag
                    port.conn = false;
                end
            end
            disp('disconnect ports');
        end
    end
    
    %%===============  STATIC PROTECTED METHODS  ======================
    
    methods(Static = true,Access = protected)
        function portKeys = sensorsPartsLists2keys(sensorList,partsList)
            % DEBUG: remove acc and respective ports because they are not
            % integrated on Gazebo yet
            partsList = partsList(~ismember(sensorList,'acc'));
            sensorList = sensorList(~ismember(sensorList,'acc'));
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
                'UniformOutput',false);              % cannot concatenate lists from iterations
            portKeys = [portKeys{:}];                % concatenate them here!
        end
    end
    
    %%===============  STATIC METHODS  ================================

    methods(Static = true,Access = public)
        function clean()
            % clean yarp ports
            system('yarp clean');
        end
        
        function status = doesPIDmatchDatadumper(pid)
            % get the matching process (only the command wo the parameters)
            [status,pidCmdRef] = system(['ps -cp ' num2str(pid)]);
            if status
                warning('Couldn''t verify the PID');
            end
            % parse the first 4 columns into a 1x4 cell
            pidCmdRef_cols     = textscan(pidCmdRef,'%s %s %s %s');
            % expand cell contents and filter to get the array of cells as follows:
            % PID CMD
            % XXX XXXXX
            pidCmdRef_array    = [pidCmdRef_cols{[1 4]}];
            % expected PID/CMD to compare to
            generatedPidCmd_array = {'PID','CMD';num2str(pid),'yarpdatadumper'};
            similar = cellfun(...
                @(elem1,elem2) strcmp(elem1,elem2),...
                pidCmdRef_array(:),generatedPidCmd_array(:),...
                'UniformOutput',false);
            status = (sum(~[similar{:}]) == 0);
        end
    end
end


