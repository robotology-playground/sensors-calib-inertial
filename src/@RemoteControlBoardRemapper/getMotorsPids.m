function [readPids,readPidsMatArray] = getMotorsPids(obj,pidCtrlType,jointsIdxList)

% Get the encoders values
ipids = obj.driver.viewIPidControl();
readPids = yarp.PidVector();
readPids.resize(length(jointsIdxList));
readPid = yarp.Pid();

% Read PID values for each joint/motor
for idx = 1:length(jointsIdxList)
    cLikeIdx = idx-1; % C like index
    ipids.getPid(pidCtrlType,cLikeIdx,readPid);
    readPids.set(cLikeIdx,readPid);
    readPidsMatArray(idx) = struct(...
        'Kp',readPid.K,'Kd',readPid.Kd,'Ki',readPid.Ki,...
        'max_int',readPid.max_int,'max_output',readPid.max_output,...
        'scale',readPid.scale);
end

end
