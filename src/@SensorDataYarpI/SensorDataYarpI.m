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
        portFromPart = {};
        dataPath;
    end
    
    methods(Access = public)
        function obj = SensorDataYarpI(robotName,dataPath)
            % Save parameters, define port names and data file path
            obj.robotName = robotName;
            obj.dataPath = dataPath;
            obj.portFromPart = obj.buildPortFromPart(robotName);
            disp('const');
        end
        
        function delete(obj)
            disp('dest');
        end
        
        function newLog(obj,parts)
            disp('newLog');
        end
        
        function closeLog(obj)
            disp('closeLog');
        end
        
        function connect(obj,varargin)
            disp('con');
        end
        
        function disconnect(obj,varargin)
            disp('disc');
        end
    end
    
    methods(Access = protected)
        % only this class and derivates should build the port mapping from
        % the configuration file
        function portFromPart = buildPortFromPart(obj,robotName)
            portFromPart = {};
            disp('buildPortsMapping');
        end
        
        % we want to avoid several logs in the same part folder (for
        % instance "/icub/left_leg/inertialMTB","/icub/left_leg/inertialMTB_00001" etc..
        % so these methods are internally called by newLog() and closeLog()
        % which handles the switching to a new folder when required.
        function openPorts(obj,ports)
            disp('open');
        end
        
        function closePorts(obj,ports)
            disp('close')
        end
    end
    
end
