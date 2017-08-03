function [ ok ] = setMotorsPWM( obj,jointsIdxList,pwmVec )
%Set PWM values set for a set of motor indexes
%   (for calibration purpose).
%   The motor indexes are the same as for the joints.
%   There is no concept of coupled motors in the control board
%   remapper.

% map a PWM controller
ipwm = obj.driver.viewIPWMControl();

% convert parameters to types handled by the bindings API
jointsVec = jointsIdxList-1; % C++ like indexes

% configure mode for specified joints
for idx = 1:numel(jointsVec)
    ok = ipwm.setRefDutyCycle(jointsVec(idx),pwmVec(idx));
    if ~ok
        error(['Couldn''t set the PWM value for joint ' num2str(jointsVec(idx)') '!!']);
    end
end

end
