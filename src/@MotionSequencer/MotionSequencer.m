classdef MotionSequencer < handle
    % Joint controller reaching each joint position set of a sequence
    %   This class processes a sequence of position sets, each position set 
    %   defining the set of joint positions to reach in a synchronous way.
    %   The class methods produce inputs to the remote control board
    %   remapper moveToPos method.
    
    properties(SetAccess = protected, GetAccess = public)
        calibApp;
        robotName;
        sequences;
        logCmd;
        ctrlBoardRemap;
        partList = {};
    end
    
    methods
        function obj = MotionSequencer(calibApp,robotName,sequences,logCmd)
            % Init class parameters
            obj.calibApp = calibApp;
            obj.robotName = robotName;
            obj.sequences = sequences;
            obj.logCmd = logCmd;
            
            % create ctrl board remapper
            obj.ctrlBoardRemap = RemoteControlBoardRemapper(robotName,calibApp);
        end
        
        run(obj)
    end
    
    methods(Static = true, Access = public)
        seqMap = seqParams2map(seqParams)
        
        runSeq = seqMap2runner(seqParamsMap)
    end
end
