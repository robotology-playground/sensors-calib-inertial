classdef RateThread < handle
    %Runs at a fixed rate a given function.
    %   The function and execution rate is defined through the class constructor.
    
    properties (Access=protected)
        minTimerFcnSpacing@double = 0.001 % 1 ms in 'fixedSpacing' execution mode
    end
    
    properties (GetAccess=public, SetAccess=protected)
        threadTimer@timer;  % scheduling timer
        period@double  = 1; % thread period in seconds
        timeout@double = 1; % thread timeout in seconds
        rateFcn@function_handle; % for setting TimerFcn callback
        firstYarpTime@double = 0;  % for synchronisation with Yarp clock
        currentLocalTime@uint64 = uint64(0); % for synchronisation with Yarp clock
        threadClock@char = 'local'; % local clock / synced to Yarp / Yarp clock
    end
    
    methods
        function obj = RateThread(rateFcn,startFcn,stopFcn,threadClock,period,timeout)
            % set period and timeout
            obj.period = round(period,3);
            if exist('timeout','var')
                obj.timeout = timeout;
            end
            
            % Set timer function
            obj.rateFcn = rateFcn;
            
            % create the scheduling timer (default clock is 'local')
            obj.threadTimer = timer(...
                'BusyMode','drop',...           % drop current timerFcn if previous not completed
                'TasksToExecute',ceil(timeout/period),... % number of runs before the timer stops
                'UserData',false);
            if ~isempty(startFcn)
                obj.threadTimer.StartFcn = startFcn;
            end
            if ~isempty(stopFcn)
                obj.threadTimer.StopFcn = stopFcn;
            end
            
            % set timer function clock
            if exist('threadClock','var')
                obj.threadClock = threadClock;
            end
            
            % change timer clock type
            obj.setTimerFcn(obj.threadClock);
        end
        
        function setTimerFcn(obj,threadClock)
            % Reset execution mode
            switch threadClock
                case 'local'
                    % Starts immediately after the timer callback function
                    % is added to the MATLAB execution queue.
                    obj.threadTimer.ExecutionMode = 'fixedRate';
                    obj.threadTimer.Period = obj.period;
                    % Timer function
                    obj.threadTimer.TimerFcn = ...
                        @(timerObj,thisEvent) obj.rateFcn(timerObj,thisEvent,@obj.stop);
                    
                case 'localSyncYarp'
                    obj.threadTimer.ExecutionMode = 'fixedRate';
                    obj.threadTimer.Period = obj.period;
                    % Timer function
                    obj.threadTimer.TimerFcn = ...
                        @(timerObj,thisEvent) obj.localSyncYarpClock(timerObj,thisEvent,obj.rateFcn);
                    
                    % prepare Timers class of wait timers
                    Timers;
                    
                case 'yarp'
                    % Starts when the timer callback function finishes executing.
                    obj.threadTimer.ExecutionMode = 'fixedSpacing';
                    obj.threadTimer.Period = obj.minTimerFcnSpacing;
                    % Timer function
                    obj.threadTimer.TimerFcn = ...
                        @(timerObj,thisEvent) obj.yarpClock(timerObj,thisEvent,obj.rateFcn);
                    
                otherwise
                    error('Unknown thread clock sync type!!');
            end
        end
        
        function delete(obj)
            if strcmp(obj.threadTimer.Running,'on')
                stop(obj.threadTimer);
            end
            delete(obj.threadTimer);
        end
        
        function ok = run(obj,waitTimerStop)
            % latch Yarp clock and local clock
            obj.firstYarpTime = yarp.Time.now;
            obj.currentLocalTime = tic;
            % Start the timer and wait termination by 'rateFunctionH' or
            % timeout.
            start(obj.threadTimer);
            ok = true;
            if waitTimerStop
                wait(obj.threadTimer);
                % return motion done success or failure
                ok = get(obj.threadTimer,'UserData');
            end
        end
        
        function stop(obj,completion)
            % Set the completion flag (bool)
            set(obj.threadTimer,'UserData',completion);
            % stop the timer
            stop(obj.threadTimer);
        end
    end
    
    methods (Access=protected)
        function localSyncYarpClock(obj,timerObj,thisEvent,rateFcn)
            % fine adjust the period, for aavoiding thrift
            currentYarpTime = yarp.Time.now - obj.firstYarpTime;
            adjust = round(currentYarpTime - toc(obj.currentLocalTime),3);
            % adjust > 0 means that the Yarp clock is faster than the local
            % and we have to shorten the period by as much
            %timerObj.Period = timerObj.Period - adjust; => this action is
            %not possible while the timer is running
            if (adjust<-0.001)
                Timers.wait(-adjust);
            end
            
            % call the periodoc external function
            rateFcn(timerObj,thisEvent,@obj.stop);
        end
        
        function yarpClock(obj,timerObj,thisEvent,rateFcn)
            % This is the Nth iteration (N=timerObj.TasksExecuted). We wish
            % to trigger the execution of 'rateFcn()' at t=N*period.
            
            % check the elapsed Yarp time
            currentYarpTime = yarp.Time.now - obj.firstYarpTime;
            % wait depending on desired period
            yarp.Time.delay(timerObj.TasksExecuted*obj.period - currentYarpTime);
            % call the requested external timer function
            rateFcn(timerObj,thisEvent,@obj.stop);
        end
    end
    
    end
