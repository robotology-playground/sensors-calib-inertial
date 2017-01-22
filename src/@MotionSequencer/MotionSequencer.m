classdef MotionSequencer < handle
    % Joint controller reaching each joint position set of a sequence
    %   This class processes a sequence of position sets, each position set 
    %   defining the set of joint positions to reach in a synchronous way.
    %   The class methods produce inputs to the remote control board
    %   remapper moveToPos method.
    
    properties(SetAccess = protected, GetAccess = public)
        robotName;
        sequences;
        acquire;
        partList = {};
    end
    
    methods
        function obj = MotionSequencer(robotName,sequences,acquire)
            obj.robotName = robotName;
            obj.sequences = sequences;
            obj.acquire = acquire;
        end
        
        function run(obj)
            % read next position step from the sequencer
            
            % if 'acquire' flag is on, start the logging for the parts active in
            % current sequence
            
            % run the sequencer step
            
            % wait for motion completion
            
        end
    end
    
end

% % iteratively trigger next motion and acquire data
% 
% 
% ctrlBoardRemap = RemoteControlBoardRemapper('icubSim',parts);
% 
% ctrlBoardRemap.moveToPos([0 0 0 0 0 0],'refVel',repmat(4,1,6));
% 
% [~,mat]=ctrlBoardRemap.getEncoders()
