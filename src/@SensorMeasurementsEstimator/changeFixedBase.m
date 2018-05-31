function changeFixedBase( obj,linkName )
%Set the fixed base index and update settings accordingly
%   Detailed explanation goes here

% Base link index for later applying forward kynematics
obj.base_link_index = obj.estimator.model.getFrameIndex(linkName);

% Specify unknown wrenches (unknown Full wrench applied at the origin of the base_link frame)
% The fullBodyUnknowns is a class storing all the unknown external wrenches acting on
% the robot: we consider the pole/ground reaction on the base link as the only
% external force.
obj.fullBodyUnknowns.clear();
obj.fullBodyUnknowns.addNewUnknownFullWrenchInFrameOrigin(...
    obj.estimator.model, ...
    obj.base_link_index);

end
