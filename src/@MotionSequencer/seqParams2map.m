function seqMap = seqParams2map( calibedPart,calibedSensors,seqParams )
%seqParams2map Convert the sequence from input format to map
%   The sequence parameters shall be indexed by pos/part,vel/part and sensor/part keys,
%   actually required for feeding the control board driver and opening the right yarp
%   ports for dumping the sensor data (joints, accelerometers, gyros,
%   etc...).
%   'seqParams' is defined for 1 single part ('calibedPart') and 1 or more
%   sensor modalities ('calibedSensors').

% Split each field (list) of 'seqParams' into columns. Each column will be an
% element of the final map.
labels = num2cell(seqParams.labels,1);
val = num2cell(seqParams.val,1);
emptyValColumn = cell(size(val{1}));

% Add calib label with 'calibedParts' and 'calibedSensors' information
[calibLabels,calibedVal] = cellfun(...
    @(calibedSensor) deal(...
    {'calib'; calibedSensor; calibedPart},...  % 2-create a 'calib' label
    emptyValColumn),...                        % 3-with empty value section
    calibedSensors,...             % 1-for each sensor...
    'UniformOutput', false);       % 4-don't concatenate lists from iterations
% concatenate with 'seqParams'
val = [val calibedVal];
labels = [labels calibLabels];

% Bundle them together.
values = cellfun(...
    @(list1,list2) struct('labels',{list1},'val',{list2}),...
    labels,val,...
    'UniformOutput', false);

% 'labels' is now a list of pairs {<sensor>;<part>}, each pair being
% a unique identifier of a sub-sequence (1 column of 'seqParams')
keys = cellfun(@(aList) [aList{:}],labels,'UniformOutput', false);

% build map
seqMap = containers.Map(keys,values);

end

