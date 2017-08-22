function jmCouplings = getJMcouplings( obj,jointNameList )
%Get the list of joint/motor couplings connected to the joints in 'jointNameList'
%   Detailed explanation goes here

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'jointName',jointNameList};

% query data
jmCouplings = obj.getPropList(inputProp,'jmCoupling');

end
