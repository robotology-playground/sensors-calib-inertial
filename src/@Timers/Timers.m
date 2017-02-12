classdef Timers < handle
    %Handler of timers
    %   This class provides services related to timers handling:
    %   - it can create a timer for handling blocking delays
    %     (the used timer is a static attribute)
    
    properties(Constant = true, GetAccess = public)
        waitTimer = Timers.staticTimer();
    end
    
    methods(Static = true)
        % Create static timer for delay handling
        function aTimer = staticTimer(varargin)
            aTimer = timer('ExecutionMode','singleShot','TimerFcn',@(~,~){});
        end
        
        % Wait for a delay in seconds (blocking)
        function wait(delay)
            set(Timers.waitTimer,'StartDelay',delay);
            start(Timers.waitTimer);
            wait(Timers.waitTimer);
        end
    end
    
end

