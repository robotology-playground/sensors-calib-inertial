classdef RemoteControlBoardRemapper < handle
    % This class creates a YARP network device and a remote controlboard
    % remapper device for controlling any desired joint through the YARP
    % ports.
    %
    % robotname : [string] 'icub' or 'icubSim'
    % jointsList: [list of strings] for instance {'l_hip_pitch','l_hip_roll','l_knee'}
    %
    
    properties(Constant)
        defaultSpeed = 10; % m/s
        defaultAcc   = 2;  % m/s^2
    end
    
    properties(SetAccess = protected, GetAccess = public)
        net;
        robotName;
        jointsList={};
        % YARP objects
        axesNames; axesList; remoteControlBoards; remoteControlBoardsList;
        options;
        driver;
        uninitYarpAtDelete = false;
    end
    
    methods
        %% Constructor
        function obj = RemoteControlBoardRemapper(robotName,portsPrefix)
            % Create YARP Network device, to initialize YARP classes for communication
            if ~yarp.Network.initialized
                yarp.Network.init();
                obj.uninitYarpAtDelete = true;
            end
            
            % Save robot name
            obj.robotName = robotName;
            
            % Create a RemoteControlBoardRemapper device
            % for controlling just the torso+head chain
            % (see http://www.yarp.it/classyarp_1_1dev_1_1remoteControlBoardRemapper.html)
            obj.options = yarp.Property('(device remotecontrolboardremapper)');
            
            % Add port prefix
            obj.options.put('localPortPrefix',['/' portsPrefix]);
            
            % Create a bottle with a list of the axis names
            obj.axesNames = yarp.Bottle();
            obj.axesList = obj.axesNames.addList();
            
            % Create a bottle with a list of the axis control boards
            obj.remoteControlBoards = yarp.Bottle();
            obj.remoteControlBoardsList = obj.remoteControlBoards.addList();
        end
        
        %% Destructor
        function delete(obj)
            obj.close();
            if obj.uninitYarpAtDelete
                yarp.Network.fini();
            end
        end
        
        %% Open ports
        open(obj,partList)
        
        %% Close ports
        function close(obj)
            obj.driver.close();
        end
        
        %% Read joint encoders
        [readedEncoders,readEncsMat] = getEncoders(obj)
        
        %% Write joint encoders
        success = setEncoders(obj,desiredPosMat,refType,refParamsMat,wait,varargin)
        
        %% Wait for motion to be completed
        success = waitMotionDone(obj,timeout)
    end
    
    methods(Static = true)
        %% matlab <-> yarp c++ map functions
        function matArray = toMatlab(self)
            matArray = str2num(self.toString_c());
        end
        
        function fromMatlab(self,matArray)
            for iter = 1:length(matArray)
                self.set(iter-1,matArray(iter));
            end
        end
    end
    
end

