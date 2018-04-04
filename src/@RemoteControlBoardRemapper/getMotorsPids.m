function [readPids,readPidsMatArray] = getMotorsPids(obj,pidCtrlType,motorsIdxList)

% Get the encoders values
ipids = obj.driver.viewIPidControl();
readPids = yarp.PidVector();
readPids.resize(length(motorsIdxList));
readPid = yarp.Pid();

% Read PID values for each joint/motor and format the data as a structure
% array
for idx = 1:length(motorsIdxList)
    cLikeIdx = idx-1; % C like index
    ipids.getPid(pidCtrlType,cLikeIdx,readPid);
    readPids.set(cLikeIdx,readPid);
    readPidsMatArray(idx) = struct(...
        'Kp',readPid.K,'Kd',readPid.Kd,'Ki',readPid.Ki,...
        'max_int',readPid.max_int,'max_output',readPid.max_output,...
        'scale',readPid.scale);
end

end
