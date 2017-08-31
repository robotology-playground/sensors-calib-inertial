function jointNameList = getCpldJointSharingIdx( obj,motorNameList )
%Get joints sharing the same indexes as the given motors
%   Detailed explanation goes here

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'cpldMotorSharingIdx',motorNameList};

% query data
jointNameList = obj.getPropList(inputProp,'jointName');

end
