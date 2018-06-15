function testRateFunction(timerObj,thisEvent,threadStopFcn,threadPeriod,aTextH)
%UNTITLED Summary of this function goes here
%   threadPeriod: thread period in seconds
persistent firstYarpTime;
persistent currentLocalTime;

if (timerObj.TasksExecuted <= 2)
    % latch Yarp clock and local clock
    firstYarpTime = yarp.now;
    currentLocalTime = tic;
end

% compute the error
currentYarpTime = yarp.now - firstYarpTime;
localTimeErr = currentYarpTime - toc(currentLocalTime);
yarpTimeErr = currentYarpTime - (timerObj.TasksExecuted-2)*threadPeriod;

% Refresh text window
newText = sprintf([...
    'ellapsed Yarp time = %f \n'...
    'Error w.r.t. local time = %f \n'...
    'Error w.r.t. Yarp time = %f'],...
    currentYarpTime,localTimeErr,yarpTimeErr);
set(aTextH,'String',newText);

% Displaying all the below information can cause the rate function
% execution time to thrift.

% disp([thisEvent.Type ' executed '...
%     datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
% disp(timerObj.TasksExecuted);
% disp(timerObj.InstantPeriod);
% disp(timerObj.AveragePeriod);

if (timerObj.TasksExecuted == 2000)
    % stop the timer
    threadStopFcn(true);
end

end

