function jmCouplings = getJMcouplings( obj,inputType,jointOrMotorNameList )
%Get the list of joint/motor couplings connected to the joints or motors in 'jointOrMotorNameList'
%   Detailed explanation goes here

switch inputType
    case 'joints'
        inputData = {'jointName',jointOrMotorNameList};
    case 'motors'
        inputData = {'cpldMotorSharingIdx',jointOrMotorNameList};
    otherwise
        error('getJMcouplings: inputType should be ''joints'' or ''motors !!''');
end

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = inputData;

% query data
jmCouplings = obj.getPropList(inputProp,'jmCoupling');

end
