function refreshModelConfig( obj,modelName )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Remove previous models (leftovers)
rmpath(genpath('../models'));
% Add path for model configuration files
addpath(['../models/' modelName],'-begin');

% Refresh link to part mapping
mappingContainer = UI.getMappingFromIniFile('link2partMappingIni');
obj.link2partMapping = mappingContainer.outputData;

end
