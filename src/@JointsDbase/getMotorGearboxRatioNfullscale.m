function [ gearboxDqM2Jratio,fullscalePWM ] = getMotorGearboxRatioNfullscale( obj,motorNameList )
%Get the gearbox ratios and fullscale values for a given list of motors

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'cpldMotorSharingIdx',motorNameList};

% query data
gearboxRatioNfullscaleMtx = obj.getMultiPropList(inputProp,{'gearboxDqM2Jratio','fullscalePWM'});
gearboxDqM2Jratio = gearboxRatioNfullscaleMtx(:,1);
fullscalePWM = gearboxRatioNfullscaleMtx(:,2);

end
