function parts = getPartFromMotors( obj,motorNameList )
%Get part names holding the motors
%   Detailed explanation goes here

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'cpldMotorSharingIdx',motorNameList};

% query data
parts = obj.getPropList(inputProp,'part');

end

