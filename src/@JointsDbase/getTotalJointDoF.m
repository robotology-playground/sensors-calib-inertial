function totalDoF = getTotalJointDoF( obj,jointList )
%getTotalJointDoF Get the total DoF from a given list of joints

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'jointName',jointList};

% query data
DoFvec = obj.getPropList(inputProp,'DoF');

% compute total DoF for the part
totalDoF = sum(cell2mat(DoFvec));

end
