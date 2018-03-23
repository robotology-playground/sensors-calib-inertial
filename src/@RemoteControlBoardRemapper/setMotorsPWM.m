function [ ok ] = setMotorsPWM( obj,motorsIdxList,pwmVec )
%Set the desired PWM values (0-100%) for a set of motor indexes
%   (for calibration purpose).
%   The motor indexes are the same as for the joints.
%   There is no concept of coupled motors in the control board
%   remapper.

% map a PWM controller
ipwm = obj.driver.viewIPWMControl();

% convert parameters to types handled by the bindings API
motorsVec = motorsIdxList-1; % C++ like indexes

% Convert % to duty-cycle values TBD

% configure mode for specified joints
for idx = 1:numel(motorsVec)
    ok = ipwm.setRefDutyCycle(motorsVec(idx),pwmVec(idx));
    if ~ok
        error(['Couldn''t set the PWM value for joint ' num2str(motorsVec(idx)') '!!']);
    end
end

end
