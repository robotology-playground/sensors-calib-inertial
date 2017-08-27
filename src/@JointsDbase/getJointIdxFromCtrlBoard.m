function [ jointIdxes ] = getJointIdxFromCtrlBoard( obj,jointNameList )
%Get the joint index as mapped in the motors control board server.
%   Detailed explanation goes here

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'jointName',jointNameList};

% query data
jointIdxes = obj.getPropList(inputProp,'idxInCtrlBoardServer');

end
