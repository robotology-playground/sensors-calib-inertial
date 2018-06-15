classdef RateThread_CB < RateThread
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = RateThread_CB(rateFcn,startFcn,stopFcn,threadClock,period,timeout)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@RateThread(rateFcn,startFcn,stopFcn,threadClock,period,timeout);
        end
        
        function ok = run(obj,~)
            % latch Yarp clock and local clock
            obj.firstYarpTime = yarp.now;
            obj.currentLocalTime = tic;
            % test the start/update callback-functions of the timer thread
            f = obj.threadTimer.StartFcn; f(obj.threadTimer,[]);
            yarp.delay(obj.period);
            f = obj.threadTimer.TimerFcn; f(obj.threadTimer,[]);
            ok = true;
        end
        
        function stop(obj,completion)
            % test the stop callback-function of the timer thread
            f = obj.threadTimer.StopFcn; f(obj.threadTimer,[]);
        end
    end
    
end

