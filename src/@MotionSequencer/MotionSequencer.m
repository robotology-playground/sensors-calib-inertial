classdef MotionSequencer < handle
    % Joint controller reaching each joint position set of a sequence
    %   This class processes a sequence of position sets, each position set 
    %   defining the set of joint positions to reach in a synchronous way.
    %   The class methods produce inputs to the remote control board
    %   remapper moveToPos method.
    
    properties(SetAccess = protected, GetAccess = public)
        calibApp;
        robotModel;
        robotName;
        sequences;
        logCmd;
        dummyCmd;
        ctrlBoardRemap;
    end
    
    methods(Access = public)
        function obj = MotionSequencer(calibApp,robotModel,sequences,logCmd)
            % Init class parameters
            obj.calibApp = calibApp;
            obj.robotModel = robotModel;
            obj.robotName = robotModel.robotName;
            % logger commands
            obj.logCmd = logCmd;
            % dummy commands (used instead of logger commands if logging is
            % not applicable
            obj.dummyCmd = obj.buildDummyCmd(logCmd);
            % Build sequences from maps to MotionSequencer runner format
            obj.sequences = cellfun(...
                @(sequence) obj.seqMap2runner(sequence),...
                sequences,...
                'UniformOutput',false);
            
            % create ctrl board remapper
            obj.ctrlBoardRemap = RemoteControlBoardRemapper(robotModel,calibApp);
        end
        
        acqSensorDataAccessor = run(obj);
    end
    
    methods(Access = protected)
        runSeq = seqMap2runner(obj,seqParamsMap);
    end
    
    methods(Static = true, Access = protected)
        function aDummyCmd = buildDummyCmd(logCmd)
            dummyFunc = @(varargin) {};
            for cField = fieldnames(logCmd)'
                field = cField{:};
                aDummyCmd.(field) = dummyFunc;
            end
        end
    end
end
