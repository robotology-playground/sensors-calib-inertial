function [motorsIdxList,matchingBitmap] = getMotorsMappedIdxes( obj,motorNameList )
%Get motors indexes as per the control board remapper mapping
%   Detailed explanation goes here

% Get the respective mapped joints names
jointNames = obj.robotModel.jointsDbase.getCpldJointSharingIdx(motorNameList);
% Get motor indices
[motorsIdxList,matchingBitmap] = obj.getJointsMappedIdxes(jointNames);

end

