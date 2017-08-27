function [ jointsIdxList,matchingBitmap ] = getJointsMappedIdxes( obj,jointNameList )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% Get the indexes of each joint from 'jointNameList' as mapped in the
% controlboard server. If a joint from 'jointNameList' is not present in
% the mapped list, trigger  warning
[matchingBitmap,indexes] = ismember(jointNameList,obj.getAxesNames());

% warning
if ~all(matchingBitmap)
    warning([...
        'joint(s) ' jointNameList(~matchingBitmap) ...
        ' is(are) not mapped in the control board server!!']);
end

% filter out unmatched joint names
jointsIdxList = indexes(matchingBitmap);

end
