classdef MotionSequencer < handle
    % Joint controller reaching each joint position set of a sequence
    %   This class processes a sequence of position sets, each position set 
    %   defining the set of joint positions to reach in a synchronous way.
    %   The class methods produce inputs to the remote control board
    %   remapper moveToPos method.
    
    properties(SetAccess = protected, GetAccess = public)
        ctrlApp;
        robotName;
        sequences;
        logStart;
        ctrlBoardRemap;
        partList = {};
    end
    
    methods
        function obj = MotionSequencer(ctrlApp,robotName,sequences,logStart,logStop)
            % Init class parameters
            obj.ctrlApp = ctrlApp;
            obj.robotName = robotName;
            obj.sequences = sequences;
            obj.logStart = logStart;
            
            % create ctrl board remapper
            obj.ctrlBoardRemap = RemoteControlBoardRemapper(robotName,ctrlApp);
        end
        
        function run(obj)
            % process each sequence
            for sequence = obj.sequences
                % get next sequence to run
                sequence = sequence{:};
                
                % open ctrl board remapper driver
                obj.ctrlBoardRemap.open(sequence.part);
                
                for seqIdx = 1:size(sequence.pos,1)
                    % get next position, velocity and acquire flag from the
                    % sequence. Get concatenated matrices for all parts
                    pos = cell2mat(sequence.pos{seqIdx,:});
                    vel = cell2mat(sequence.vel{seqIdx,:});
                    acquire = cell2mat(sequence.acquire{seqIdx,:});
                    
                    % Stop logging of parts for which 'acquire' flag is off
                    % Start logging of parts for which 'acquire' flag is on
                    obj.logStop(sequence.part(~acquire));
                    obj.logStart(sequence.part(acquire));
                    
                    % run the sequencer step
                    obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel);
                    
                    % wait for motion completion (timeout in seconds)
                    obj.ctrlBoardRemap.waitMotionDone(60);
                end
                % Stop logging of last step
                obj.logStop(sequence.part);
            end
        end
    end
    
end
