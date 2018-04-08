function [readPids,readPidsMatArray] = getMotorsPids(obj,pidCtrlType,motorsIdxList)

% Get the encoders values
ipids = obj.driver.viewIPidControl();
readPids = yarp.PidVector();
readPids.resize(length(motorsIdxList));
readPid = yarp.Pid();
% readPidsMatArray(1:length(motorsIdxList)) = ...
%     struct('kp',0,'kd',0,'ki',0,'max_int',0,'max_output',0,'scale',1);

% Translate requested PID type in vocab
pidTypeVocab = obj.vocab2pidType(pidCtrlType);

% Read PID values for each joint/motor and format the data as a structure
% array
for idx = 1:length(motorsIdxList)
    cLikeIdx = idx-1; % C like index
    ipids.getPid(pidTypeVocab,cLikeIdx,readPid); % (*)
    readPids.setbrace(readPid,cLikeIdx);
    readPidsMatArray(idx) = struct(...
        'Kp',readPid.kp,'Kd',readPid.kd,'Ki',readPid.ki,...
        'max_int',readPid.max_int,'max_output',readPid.max_output,...
        'scale',readPid.scale);
end

end

% (*) 'readPid' should have been a pointer to a yarp.Pid instead a of a
% yarp.Pid. Probably Swig replaces it with swig_this(readPid) which returns
% the pointer on the object 'readPid'.
