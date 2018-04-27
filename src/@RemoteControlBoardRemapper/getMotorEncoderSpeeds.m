function [readEncSpeeds] = getMotorEncoderSpeeds(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncodersSpeeds = yarp.Vector();
readAllEncodersSpeeds.resize(length(obj.motorsList));
imotorencs.getMotorEncoderSpeeds(readAllEncodersSpeeds.data());
readAllEncSpeeds=RemoteControlBoardRemapper.toMatlab(readAllEncodersSpeeds);

% select sub vector
readEncSpeeds=readAllEncSpeeds(motorsIdxList);

end
