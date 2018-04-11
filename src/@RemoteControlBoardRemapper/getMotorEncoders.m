function [readEncs,timeEncs] = getMotorEncoders(obj,motorsIdxList)

% getMotorEncodersTimed() NOT WORKING FOR NOW !!!

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncoders = yarp.Vector();
% timeAllEncoders = yarp.Vector();
readAllEncoders.resize(length(obj.motorsList));
% timeAllEncoders.resize(length(obj.motorsList));
% imotorencs.getMotorEncodersTimed(readAllEncoders.data(),timeAllEncoders.data());
imotorencs.getMotorEncoders(readAllEncoders.data());
readAllEncs = RemoteControlBoardRemapper.toMatlab(readAllEncoders);
% timeAllEncs = RemoteControlBoardRemapper.toMatlab(timeAllEncoders);

% select sub vector
readEncs = readAllEncs(motorsIdxList);
% timeEncs = timeAllEncs(motorsIdxList);
timeEncs(1:numel(readEncs)) = yarp.Time.now();

end
