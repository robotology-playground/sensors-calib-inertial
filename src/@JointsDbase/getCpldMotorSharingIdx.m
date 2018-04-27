function motorNameList = getCpldMotorSharingIdx( obj,jointNameList )
%Get motors sharing the same indexes as the given joints
%   Detailed explanation goes here

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'jointName',jointNameList};

% query data
motorNameList = obj.getPropList(inputProp,'cpldMotorSharingIdx');

end
