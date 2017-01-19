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
        partList = {};
        jointsList = {};
        options;
        driver;
    end
    
    methods
        function obj = RemoteControlBoardRemapper(robotName,partList)
            % Create YARP Network device, to initialize YARP classes for communication
            iDynTree.Vector3(); %WORKAROUND for loading yarp right after.
            obj.net = yarp.Network();
            obj.net.init();
                        
            % Save constructor parameters
            obj.robotName = robotName;
            obj.partList = partList;
            for part = partList
                obj.jointsList = [obj.jointsList RobotModel.jointsListFromPart(part{:})];
                % {:} converts from cell to string
            end
            
            % Create a RemoteControlBoardRemapper device 
            % for controlling just the torso+head chain
            % (see http://www.yarp.it/classyarp_1_1dev_1_1remoteControlBoardRemapper.html)
            obj.options = yarp.Property('(device remotecontrolboardremapper)');
            
            % Create a bottle with a list of the axis names and add it to the options
            axesNames = yarp.Bottle();
            axesList = axesNames.addList();
            for joint = obj.jointsList
                axesList.addString(joint{:});
            end
            obj.options.put('axesNames',axesNames.get(0)) % add the pair {'<property name>',<pointer to object>}
            
            % Create a bottle with a list of the axis control boards and add it to the options
            remoteControlBoards = yarp.Bottle();
            remoteControlBoardsList = remoteControlBoards.addList();
            for part = partList
                remoteControlBoardsList.addString(['/' robotName '/' part{:}]);
            end
            obj.options.put('remoteControlBoards',remoteControlBoards.get(0));
            
            % Add port prefix
            obj.options.put('localPortPrefix','/test');
            
            % Open the driver
            obj.driver = yarp.PolyDriver();
            if (~obj.driver.open(obj.options))
                error('Couldn''t open the driver');
            end
        end
        
        function delete(obj)
            obj.net.fini();
        end
        
        function [readedEncoders,readEncsMat] = getEncoders(obj)
            % Get the encoders values
            iencs = obj.driver.viewIEncoders();
            readedEncoders = yarp.Vector();
            readedEncoders.resize(length(obj.jointsList));
            iencs.getEncoders(readedEncoders.data());
            readEncsMat=RemoteControlBoardRemapper.toMatlab(readedEncoders);
        end
        
        function moveToPos(obj,desiredPosMat,refType,refParamsMat)
            % refType: 'refVel','refAcc'
            % refParamsMat: reference velocities or accs
            % depending on refType
            
            % Check desired positions size
            if length(desiredPosMat) ~= length(obj.jointsList)
                error('wrong input vector size!');
            end
            % Configure positions
            ipos = obj.driver.viewIPositionControl();
            desiredPositions = yarp.Vector(length(obj.jointsList));
            desiredPositions.zero();
            RemoteControlBoardRemapper.fromMatlab(desiredPositions,desiredPosMat);
            % Set the reference vel or acc
            refParams = yarp.Vector(length(obj.jointsList));
            refParams.zero();
            RemoteControlBoardRemapper.fromMatlab(refParams,refParamsMat);
            switch refType
                case 'refVel'
                    % Set ref speeds
                    ipos.setRefSpeeds(refParams.data());
                case 'refAcc'
                    % Set ref accelerations
                    ipos.setRefAccelerations(refParams.data());
                otherwise
                    error('Unsupported reference type');
            end
            % Run the motion
            ipos.positionMove(desiredPositions.data());
        end
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

