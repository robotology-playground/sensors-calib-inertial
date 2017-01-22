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
        partList = {};
        dataPath;
    end
    
    methods
        function obj = SensorDataYarpI(robotName,parts,dataPath)
            disp('const');
        end
        
        function delete(obj)
            disp('dest');
        end
        
        function openPorts(obj,varargin)
            disp('open');
        end
        
        function closePorts(obj,varargin)
            disp('close')
        end
        
        function connect(obj,varagin)
            disp('con');
        end
        
        function disconnect(obj,varargin)
            disp('disc');
        end
    end
    
end
