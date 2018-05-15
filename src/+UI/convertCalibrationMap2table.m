function [ aTable ] = convertCalibrationMap2table( calibMap )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% convert to struct array
structArray = cellfun(@(elem) struct(elem),calibMap.values,'UniformOutput',true);

% convert units
% convertedKc = arrayfun(@(elem) elem.Kc*32000/100,structArray,'UniformOutput',false);
% [structArray.Kc] = deal(convertedKc{:});
% convertedKv = arrayfun(@(elem) elem.Kv*pi/180,structArray,'UniformOutput',false);
% [structArray.Kv] = deal(convertedKv{:});

% convert to table
aTable = struct2table(structArray);
aTable.Properties.VariableUnits = {'','Nm/dutycycle%','Nm','Nm/rad.s-1','Nm','Nm'};

end
