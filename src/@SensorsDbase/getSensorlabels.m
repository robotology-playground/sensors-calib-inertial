function sensorLabelList = getSensorlabels( part,sensorUiIDlist )
%getSensorlabels Get sensor labels identified by the set <part,sensorUiIDlist>.
%   'sensorUiIDlist', along with part, is the UI set of parameters
%   identifying a unique sensor.
%   ex of returned sensor label: [11b3_acc]
%

persistent part2mtbNum;

part2mtbNum = containers.Map(...
    {'left_arm','right_arm','left_leg','right_leg','torso','head'},...
    {'1b','2b','10b','11b','9b','1x'});

hwIds = arrayfun(...
    @(shortCode) [part2mtbNum(part) num2str(shortCode)],...
    sensorUiIDlist,...
    'UniformOutput',false);

% build query (input properties to match)
inputProp.queryFormat = 2;
inputProp.queryData = {'sensorHwId',hwIds};

% query data
labelList = obj.getPropList(inputProp,'sensorLabel');
sensorLabelList = labelList(:)';

end
