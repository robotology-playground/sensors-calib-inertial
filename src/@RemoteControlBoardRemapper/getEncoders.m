function [readedEncoders,readEncsMat] = getEncoders(obj)

% Get the encoders values
iencs = obj.driver.viewIEncoders();
readedEncoders = yarp.Vector();
readedEncoders.resize(length(obj.jointsList));
iencs.getEncoders(readedEncoders.data());
readEncsMat=RemoteControlBoardRemapper.toMatlab(readedEncoders);

end
