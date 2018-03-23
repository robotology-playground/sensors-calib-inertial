function [readEncoders,readEncsMat] = getMotorEncoders(obj,motorsIdxList)

% Get all the encoders values
imotorencs = obj.driver.viewIMotorEncoders();
readAllEncoders = yarp.Vector();
readAllEncoders.resize(length(obj.jointsList));
imotorencs.getMotorEncoders(readAllEncoders.data());

% select sub vector
cLikeMotorsIdxList = num2cell(motorsIdxList-1); % C++ like indexes
readEncoders = readAllEncoders.subVector(cLikeMotorsIdxList{:});
readEncsMat=RemoteControlBoardRemapper.toMatlab(readEncoders);

end
