function parts = getPartsFromList( jmCouplings )
%Get part name from each joint/motor coupling
%   Detailed explanation goes here

% Array of couplings. We can directly concatenate the couplings using
% horzcat command since they are line cell arrays.
couplingsArray = [jmCouplings{:}];
parts = {couplingsArray.part};

end
