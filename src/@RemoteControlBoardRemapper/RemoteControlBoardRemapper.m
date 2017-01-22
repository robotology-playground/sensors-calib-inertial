classdef RemoteControlBoardRemapper < handle
    % This class creates a YARP network device and a remote controlboard
    % remapper device for controlling any desired joint through the YARP
    % ports.
    %
    % robotname : [string] 'icub' or 'icubSim'
    % jointsList: [list of strings] for instance {'l_hip_pitch','l_hip_roll','l_knee'}
    %
    
    properties (SetAccess = protected, GetAccess = public)
        net;
        robotName;
        jointsList={};
        % YARP objects
        axesNames; axesList; remoteControlBoards; remoteControlBoardsList;
        options;
        driver;
    end
    
    methods
        function obj = RemoteControlBoardRemapper(robotName,portsPrefix)
            % Create YARP Network device, to initialize YARP classes for communication
            iDynTree.Vector3(); %WORKAROUND for loading yarp right after.
            obj.net = yarp.Network();
            obj.net.init();
            
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
        
        open(obj,partList)
        
        function close(obj)
            obj.driver.close();
        end
        
        function delete(obj)
            obj.close();
            obj.net.fini();
        end
        
        [readedEncoders,readEncsMat] = getEncoders(obj)
        
        setEncoders(obj,desiredPosMat,refType,refParamsMat)
    end
    
    methods(Static = true)
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

