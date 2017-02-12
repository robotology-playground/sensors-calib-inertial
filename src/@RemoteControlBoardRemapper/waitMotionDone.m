function success = waitMotionDone(obj,timeout)
%Waits for last programmed joint position to be reached.
%   Every 100 ms, we check for the joints motion completion. if all joints
%   reached their programmed position before the timeout, then 'true' is
%   returned, otherwise 'false' is returned.

% define polling function (timer callback)
ipos = obj.driver.viewIPositionControl();
timerFcn = @(timerObj,~) checkMotionDone(timerObj,ipos);

% create timeout timer
poller = timer(...
    'ExecutionMode','fixedRate',...
    'Period',0.1,...
    'TasksToExecute',timeout/0.1,...
    'TimerFcn',timerFcn,...
    'UserData',false);

% start timer and wait
start(poller);
wait(poller);

% return motion done success or failure
success = get(poller,'UserData');

end

% polling function
function checkMotionDone(obj,ipos)

% check if motion is done
if ipos.isMotionDone()
    % motion is done. Set the completion flag to true
    set(obj,'UserData',true);
    % stop the timer
    stop(obj);
end

end
