function [readEncs,timeEncs] = getMotorEncoders(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncoders = yarp.Vector();
timeAllEncoders = yarp.Vector();
readAllEncoders.resize(length(obj.motorsList));
timeAllEncoders.resize(length(obj.motorsList));
imotorencs.getMotorEncodersTimed(readAllEncoders.data(),timeAllEncoders.data());
readAllEncs = RemoteControlBoardRemapper.toMatlab(readAllEncoders);
timeAllEncs = RemoteControlBoardRemapper.toMatlab(timeAllEncoders);

% select sub vector
readEncs = readAllEncs(motorsIdxList);
timeEncs = timeAllEncs(motorsIdxList);
% DEBUG: only the first element has a tiing <> 0, so use that value for the
% others
timeEncs(:) = timeEncs(1);

end
