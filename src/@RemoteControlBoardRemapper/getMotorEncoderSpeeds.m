function [readEncSpeeds] = getMotorEncoderSpeeds(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncodersSpeeds = yarp.Vector();
readAllEncodersSpeeds.resize(length(obj.jointsList));
imotorencs.getMotorEncoderSpeeds(readAllEncodersSpeeds.data());

% select sub vector
cLikeMotorsIdxList = num2cell(motorsIdxList-1); % C++ like indexes
readEncoderSpeeds = readAllEncodersSpeeds.subVector(cLikeMotorsIdxList{:});
readEncSpeeds=RemoteControlBoardRemapper.toMatlab(readEncoderSpeeds);

end
