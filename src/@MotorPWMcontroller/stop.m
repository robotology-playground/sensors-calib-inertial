function [ ok ] = stop( obj )
%Stop the PWM controller.
%   This also restores the previous control mode for the named motor and
%   eventual coupled motors.

if obj.running
    % stop the thread if it's running. As the thread stops, it should
    % trigger the restoration of the previous control mode
    obj.ctrllerThread.stop(true);
    ok = true;
else
    % just restore the previous control mode
    warning('Trying to stop a non running PWM controller thread!');
    ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,obj.couplingPrevMode);
end

end
