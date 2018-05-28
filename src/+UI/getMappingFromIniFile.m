function [ mapping ] = getMappingFromIniFile( mappingIniScript )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

run(mappingIniScript);

mapping.inputType = mappingIn{1,1};
mapping.inputData = mappingIn(2:end,1);
mapping.fieldNames = mappingIn(1,2:end);

dataArray = cell2struct(mappingIn(2:end,2:end),mapping.fieldNames,2);

for idx = 1:numel(mapping.inputData)
    data.(mapping.inputData{idx}) = dataArray(idx);
end

mapping.outputData = data;

end
