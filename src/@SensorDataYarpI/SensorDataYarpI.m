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
        portFromSensor = {}; % sensor type to port name LUT
        openports = {};      % current open ports
        connports = {};      % current connected ports
        errorMsg = '';       % filled by any method of the class
    end
    
    methods(Access = public)
        function obj = SensorDataYarpI(robotName,dataFolderPath)
            % Save parameters, define port names and data file path
            obj.robotName = robotName;
            obj.dataFolderPath = dataFolderPath;
            obj.buildportFromSensor();
        end
        
        function delete(obj)
            % disconnect and close open ports
            obj.closeLog();
            disp('dest');
        end
        
        function newLog(obj,parts)
            
            disp('newLog');
        end
        
        function closeLog(obj)
            % disconnect all connected ports
            obj.discPorts(obj.connports);
            % close all open ports
            if obj.closePorts()
                error(obj.errorMsg);
            end
            disp('closeLog');
        end
        
        function connect(obj,parts)
            disp('conn');
        end
        
        function disconnect(obj,parts)
            disp('disc');
        end
    end
    
    methods(Access = protected)
        % only this class and derivates should build the port mapping from
        % the configuration file
        function buildportFromSensor(obj)
            % init parameters from config file
            run yarpPortNameRules;
            sensorType = {'joint','acc','imu'};
            portNamingRule = {...
                eval(['@(part)' joints_port_rule]),...
                eval(['@(part)' accSensors_port_rule]),...
                eval(['@(part)' imuSensors_port_rule])};
            obj.portFromSensor = containers.Map(sensorType,portNamingRule);
            disp('buildPortsMapping');
        end
        
        % we want to avoid several logs in the same part folder (for
        % instance "/icub/left_leg/inertialMTB","/icub/left_leg/inertialMTB_00001" etc..
        % so these methods are internally called by newLog() and closeLog()
        % which handles the switching to a new folder when required.
        function success = openPorts(obj,ports)
            % open list of ports through yarpdatadumper
            for port = ports
                success = system(['yarpdatadumper --name /dumper' port{:} ' --type bottle &']);
                if success
                    obj.errorMsg = ['couldn''t open port ' port{:} '!'];
                    return;
                end
            end
            % save list of open ports
            obj.openports = ports;
            disp('open ports');
        end
        
        function success = closePorts(obj)
            % close all previously open ports through yarpdatadumper
            for port = obj.openports
                success = system('pkill -9 yarpdatadumper');
                if success
                    obj.errorMsg = ['couldn''t close port ' port{:} '!'];
                    return;
                end
            end
            % empty list of open ports
            obj.openports = {};            
            disp('close ports')
        end
        
        function success = connPorts(obj,ports)
            % closed ports trying to be connected are...
            stillClosedPorts = ~ismember(ports,obj.openports);
            % return error if some ports to connect are closed
            if sum(stillClosedPorts)>0
                obj.errorMsg = ['Trying to connect closed ports: '...
                    ports(stillClosedPorts)];
                return;
            end
            
            % connect ports
            % 'yarp connect <output port> <input port>
            for port = ports
                success = system(['yarp connect --name /dumper' port{:} ' --type bottle &']);
                if success
                    obj.errorMsg = ['couldn''t open port ' port{:} '!'];
                    return;
                end
            end
            % save list of open ports
            obj.openports = ports;
            disp('open');
        end
    end
    
end

% parts = {...
%     'left_leg','right_leg',...
%     'left_arm','right_arm',...
%     'torso','head'};


