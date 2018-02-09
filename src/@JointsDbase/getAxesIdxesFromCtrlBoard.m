function [ AxesIdxes ] = getAxesIdxesFromCtrlBoard( obj,axesType,jointOrMotorNameList )
%Get the joint index as mapped in the motors control board server.
%   Detailed explanation goes here

switch axesType
    case 'joints'
        inputData = {'jointName',jointOrMotorNameList};
    case 'motors'
        inputData = {'cpldMotorSharingIdx',jointOrMotorNameList};
    otherwise
        error('getAxesIdxesFromCtrlBoard: axesType should be ''joints'' or ''motors !!''');
end

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = inputData;

% query data
AxesIdxes = cell2mat(obj.getPropList(inputProp,'idxInCtrlBoardServer'));

end
