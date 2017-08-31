function motorNameList = getMotorsFromList( jmCouplings )
%Get all motor names from the couplings list
%   Detailed explanation goes here

% Array of couplings. We can directly concatenate the couplings using
% horzcat command since they are line cell arrays.
couplingsArray = [jmCouplings{:}];
motorNameList = [couplingsArray.coupledMotors];

end
