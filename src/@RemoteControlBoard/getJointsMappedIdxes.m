function [ jointsIdxList,matchingBitmap ] = getJointsMappedIdxes( obj,jointNameList )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% Get the indexes of each joint from 'jointNameList' as mapped in the
% controlboard server. If a joint from 'jointNameList' is not present in
% the mapped list, trigger  warning
[matchingBitmap,indexes] = ismember(jointNameList,obj.robotInterAxesNames);

% warning
if ~all(matchingBitmap)
    missingJoints = jointNameList(~matchingBitmap);
    warningMess = [...
        'joint(s) ' repmat('%s ',1:numel(missingJoints)) ...
        ' is(are) not mapped in the control board server!!'];
    warning(warningMess,missingJoints{:});
end

% filter out unmatched joint names
jointsIdxList = indexes(matchingBitmap);

end
