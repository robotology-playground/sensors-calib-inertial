function parts = getPartFromJMcouplings( obj,jmCouplings )
%Get part name from joint/motor group label
%   Detailed explanation goes here

parts = cellfun(...
    @(jmCoupling) jmCoupling.part,...
    jmCouplings,...
    'UniformOutput',false);

end

