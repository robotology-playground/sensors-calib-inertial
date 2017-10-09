function [jointsIdxList,matchingBitmap] = getJointsMappedIdxes( obj,jointNameList )
%UNTITLED Get joints indexes as per the control board remapper mapping
%   Detailed explanation goes here

% Get the indexes of each joint from 'jointNameList' in the controlboard
% remapper joint list. If a joint from 'jointNameList' is not present in
% the mapped list, trigger  warning
[matchingBitmap,indexes] = ismember(jointNameList,obj.jointsList);

% warning
if ~all(matchingBitmap)
    warning([...
        'joint(s) ' jointNameList{~matchingBitmap} ...
        ' is(are) not mapped to the control board!!']);
end

% filter out unmatched joint names
jointsIdxList = indexes(matchingBitmap);

end
