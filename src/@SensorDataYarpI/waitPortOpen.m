function [ ok ] = waitPortOpen( obj,port,timeout )
%Waits for specified port to open.
%   Every 100 ms, we check specified port is open.

% define polling function (timer callback)
timerFcn = @(timerObj,~) checkPortIsOpen(timerObj,port);

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
ok = get(poller,'UserData');

end

% polling function
function checkPortIsOpen(obj,port)

% check if port is open
if yarp.Network.exists(port)
    % port is open. Set the completion flag to true
    set(obj,'UserData',true);
    % stop the timer
    stop(obj);
end

end
