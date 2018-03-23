function [readEncoders,readEncsMat] = getEncoders(obj)

% Get the encoders values
iencs = obj.driver.viewIEncoders();
readEncoders = yarp.Vector();
readEncoders.resize(length(obj.jointsList));
iencs.getEncoders(readEncoders.data());
readEncsMat=RemoteControlBoardRemapper.toMatlab(readEncoders);

end
