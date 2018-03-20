function testRateFunction(timerObj,thisEvent,timerStopFcn,threadPeriod)
%UNTITLED Summary of this function goes here
%   threadPeriod: thread period in seconds
persistent firstYarpTime;
persistent currentLocalTime;

if (timerObj.TasksExecuted <= 2)
    % latch Yarp clock and local clock
    firstYarpTime = yarp.Time.now;
    currentLocalTime = tic;
end

% compute the error
currentYarpTime = yarp.Time.now - firstYarpTime;
localTimeErr = currentYarpTime - toc(currentLocalTime);
yarpTimeErr = currentYarpTime - (timerObj.TasksExecuted-2)*threadPeriod;

clc;

disp(['ellapsed Yarp time = ' num2str(currentYarpTime)]);
disp(['Error w.r.t. local time = ' num2str(localTimeErr)]);
disp(['Error w.r.t. Yarp time = ' num2str(yarpTimeErr)]);

% Displaying all the below information can cause the rate function
% execution time to thrift.

% disp([thisEvent.Type ' executed '...
%     datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
% disp(timerObj.TasksExecuted);
% disp(timerObj.InstantPeriod);
% disp(timerObj.AveragePeriod);

if (timerObj.TasksExecuted == 2000)
    % stop the timer
    timerStopFcn();
end

end

