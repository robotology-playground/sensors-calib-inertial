function [readEncs,timeEncs] = getMotorEncoders(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncoders = yarp.Vector();
timeAllEncoders = yarp.Vector();
readAllEncoders.resize(length(obj.jointsList));
timeAllEncoders.resize(length(obj.jointsList));
imotorencs.getMotorEncodersTimed(readAllEncoders.data(),timeAllEncoders.data());

% select sub vector
cLikeMotorsIdxList = num2cell(motorsIdxList-1); % C++ like indexes
readEncoders = readAllEncoders.subVector(cLikeMotorsIdxList{:});
timeEncoders = timeAllEncoders.subVector(cLikeMotorsIdxList{:});
readEncs = RemoteControlBoardRemapper.toMatlab(readEncoders);
timeEncs = RemoteControlBoardRemapper.toMatlab(timeEncoders);

end
