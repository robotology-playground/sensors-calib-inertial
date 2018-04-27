function [readEncs] = getEncoders(obj)

% Get the encoders values
iencs = obj.driver.viewIEncoders();
readEncoders = yarp.Vector();
readEncoders.resize(length(obj.jointsList));
iencs.getEncoders(readEncoders.data());
readEncs=RemoteControlBoardRemapper.toMatlab(readEncoders);

end
