function [ ok ] = stop( obj )
%Stop the PWM controller.
%   This also restores the previous control mode for the named motor and
%   eventual coupled motors.

if obj.running
    % stop the thread if it's running
    obj.ctrllerThread.stop(true);
    ok = true;
else
    ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,obj.couplingPrevMode);
end

end
