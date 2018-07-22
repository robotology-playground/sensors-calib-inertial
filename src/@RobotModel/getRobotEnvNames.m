function [ robotEnvNames ] = getRobotEnvNames( modelName )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

robotNameMapping = UI.getMappingFromIniFile('robotNameMappingIni');
robotEnvNames = robotNameMapping.outputData.(modelName);
robotEnvNames.modelName = modelName;

end
