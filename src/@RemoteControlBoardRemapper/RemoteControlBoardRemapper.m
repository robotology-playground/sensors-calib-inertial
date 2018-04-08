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
        
        ctrlModeVocabDef = {...
            'idlectrl'  , y.VOCAB_CM_IDLE     ;
            'torqctrl'  , y.VOCAB_CM_TORQUE   ;
            'ctrl'      , y.VOCAB_CM_POSITION ;
            'ctrldir'   , y.VOCAB_CM_POSITION_DIRECT ;
            'velctrl'   , y.VOCAB_CM_VELOCITY ;
            'curctrl'   , y.VOCAB_CM_CURRENT  ;
            'pwmctrl'   , y.VOCAB_CM_PWM
            };
        
        ctrlMode2vocab = containers.Map(...
            RemoteControlBoardRemapper.ctrlModeVocabDef(:,1),...
            RemoteControlBoardRemapper.ctrlModeVocabDef(:,2));
        
        vocab2ctrlMode = containers.Map(...
            RemoteControlBoardRemapper.ctrlModeVocabDef(:,2),...
            RemoteControlBoardRemapper.ctrlModeVocabDef(:,1));
        
        pidTypeVocabDef = {...
            'posPID' , y.VOCAB_PIDTYPE_POSITION;
            'velPID' , y.VOCAB_PIDTYPE_VELOCITY;
            'torqPID', y.VOCAB_PIDTYPE_TORQUE  ;
            'currPID', y.VOCAB_PIDTYPE_CURRENT
            };
        
        pidType2vocab = containers.Map(...
            RemoteControlBoardRemapper.pidTypeVocabDef(:,1),...
            RemoteControlBoardRemapper.pidTypeVocabDef(:,2));
        
        vocab2pidType = containers.Map(...
            RemoteControlBoardRemapper.pidTypeVocabDef(:,1),...
            RemoteControlBoardRemapper.pidTypeVocabDef(:,2));
    end
    
    properties(SetAccess = protected, GetAccess = public)
        robotName;
        robotModel;
        jointsList={};
        motorsList={};
        % YARP objects
        axesNames; axesList; remoteControlBoards; remoteControlBoardsList;
        options;
        driver;
    end
    
    methods
        % Constructor
        function obj = RemoteControlBoardRemapper(robotModel,portsPrefix)
            % Create YARP Network device, to initialize YARP classes for communication
            if ~yarp.Network.initialized
                yarp.Network.init();
            end
            
            % Save robot model
            obj.robotModel = robotModel;
            obj.robotName = robotModel.robotName;
            
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
        
        % Destructor
        function delete(obj)
            obj.close();
        end
        
        % Open ports
        open(obj,partList)
        
        % Close ports
        function close(obj)
            obj.driver.close();
        end
        
        % Read joint encoders
        [readEncs] = getEncoders(obj);
        
        % Read motor encoders
        [readEncs,timeEncs] = getMotorEncoders(obj,motorsIdxList);
        
        % Read motor encoder speeds
        [readEncSpeeds] = getMotorEncoderSpeeds(obj,motorsIdxList);
        
        % Write joint encoders
        ok = setEncoders(obj,desiredPosMat,refType,refParamsMat,wait,varargin);
        
        % Wait for motion to be completed
        ok = waitMotionDone(obj,timeout);
        
        % Get joints indexes as per the control board remapper mapping
        [jointsIdxList,matchingBitmap] = getJointsMappedIdxes(obj,jointNameList);
        
        % Get motors indexes as per the control board remapper mapping
        [motorsIdxList,matchingBitmap] = getMotorsMappedIdxes(obj,motorNameList);
        
        % Set/Get control mode for a set of joint indexes. Supported modes are:
        % Position, Open loop (applicable for PWM, torque, current).
        ok = setJointsControlMode(obj,jointsIdxList,mode);
        [ok, modes] = getJointsControlMode(obj,jointsIdxList);
        
        % Get motor PIDs
        [readPids,readPidsMat] = getMotorsPids(obj,pidCtrlMode,motorsIdxList);
        
        % Set the desired PWM values for a set of motor indexes (for
        % calibration purpose). The motor indexes are the same as for the
        % joints. There is no concept of coupled motors in the control board
        % remapper. But if a coupled motor is set to a given control mode,
        % then all the motors in the coupling are set to the same mode.
        ok = setMotorsPWM(obj,motorsIdxList,pwmVec);
        
        % Get the PWM values (0-100%) for a set of motor indexes
        [pwmVec] = getMotorsPWM(obj,motorsIdxList);
        
        % Set the desired PWM value (0-100%) for the named motor
        ok = setMotorPWM(obj,motorName,pwm);
    end
    
    methods(Static = true)
        % matlab <-> yarp c++ map functions
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

