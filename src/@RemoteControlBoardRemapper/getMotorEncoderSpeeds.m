function [readEncoderSpeeds,readEncSpeedsMat] = getMotorEncoderSpeeds(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncoders = yarp.Vector();
readAllEncoders.resize(length(obj.jointsList));
imotorencs.getMotorEncoderSpeeds(readAllEncoders.data());

% select sub vector
cLikeMotorsIdxList = num2cell(motorsIdxList-1); % C++ like indexes
readEncoderSpeeds = readAllEncoders.subVector(cLikeMotorsIdxList{:});
readEncSpeedsMat=RemoteControlBoardRemapper.toMatlab(readEncoderSpeeds);

end
