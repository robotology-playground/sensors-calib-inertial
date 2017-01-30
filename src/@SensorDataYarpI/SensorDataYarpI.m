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
        robotName;
        dataFolderPath;      % where to create /log_xxxx/dumper/ folder
        seqDataFolderPath;
        iteratorUpdated = false;        % true if a first log has been open
        sensorType2portNameGetter = {}; % sensor type to port name LUT
        openports = {};      % current open ports with info to,from,connected
    end
    
    methods(Access = public)
        function obj = SensorDataYarpI(robotName,dataFolderPath)
            % Save parameters, define port names and data file path
            obj.robotName = robotName;
            obj.dataFolderPath = dataFolderPath;
            obj.buildSensType2portNgetter();
        end
        
        function delete(obj)
            % disconnect and close open ports
            obj.closeLog();
            disp('dest');
        end
        
        function newLog(obj,logInfo,sensorList,partsList)
            % set folder name for the data dumper
            obj.newDataSubFolderPath(logInfo);
            % close any open ports and log
            obj.closeLog();
            % create ports mapping
            [newKeyList,newPortList] = cellfun(...
                @(sensor,parts) newPortEntries(sensor,parts),...
                sensorList,partsList,...
                'UniformOutput',false);
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
            % flaten list and connect ports
            obj.connPorts(keys);
            disp('conn');
        end
        
        function disconnect(obj,sensorList,partsList)
            % generate the keys from the input lists
            keys = sensorsPartsLists2keys(sensorList,partsList);
            % flaten list and connect ports
            obj.discPorts(keys);
            disp('disc');
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
        
        function keys = sensorsPartsLists2keys(sensorList,partsList)
            % DEBUG: remove acc and respective ports
            sensorList = sensorList(~ismember(sensorList,'acc'));
            partsList = partsList(~ismember(sensorList,'acc'));
            % END debug
            
            % generate keys for one sensor
            genKeys4oneSensor = @(sensor,parts) cellfun(...
                @(part) [sensor part],...
                parts,...
                'UniformOutput',false);
            % generate keys for the whole sensor list
            portKeys = cellfun(...
                @(sensor,parts) genKeys4oneSensor(sensor,parts),...
                sensorList,partsList,...
                'UniformOutput',false);
            % flatten list
            keys = [portKeys{:}];
        end
        
        function newDataSubFolderPath(obj,logInfo)
            if ~(obj.iteratorUpdated)
                % Define a default value for 'iterator' in case no iterator
                % file exists. For reseting the iterator, just delete the file
                % 'iterator.mat' found in the dumper folder.
                iterator = 1;
                
                % Update iterator
                iteratorFilePath = [obj.dataFolderPath '/iterator.mat'];
                if exist(iteratorFilePath,'file') == 2
                    load(iteratorFilePath,'iterator');
                    iterator = iterator+1;
                end
                save(iteratorFilePath,'iterator');
                
                % Track that the update has been done
                obj.iteratorUpdate = true;
            end
            
            % Prepare log folders/files
            obj.seqDataFolderPath = [...
                obj.dataFolderPath '/' obj.robotName...
                '#' num2str(iterator) '.' logInfo.sequencerIdx];
            system(['mkdir ' obj.seqDataFolderPath],'-echo');
            fileID = fopen([obj.dataFolderPath '/log_' num2str(iterator) '.txt'],'w');
            fprintf(fileID,'control app. = %s\n',logInfo.ctrlApp);
            fprintf(fileID,'iterator = %d\n',iterator);
            fprintf(fileID,'seq Idx = %s\n',logInfo.sequencerIdx);
            fclose(fileID);
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


