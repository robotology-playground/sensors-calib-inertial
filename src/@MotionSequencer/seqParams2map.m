function seqMap = seqParams2map( seqParams )
%seqParams2map Convert the sequence from input format to map
%   The sequence parameters shall be indexed by pos/part,vel/part and sensor/part keys,
%   actually required for feeding the control board driver and opening the right yarp
%   ports for dumping the sensor data (joints, accelerometers, gyros,
%   etc...).

% Split each field (list) of setParam into columns. Each column will be an
% element of the final map.
labels = num2cell(seqParams.labels,1);
val = num2cell(seqParams.val,1);

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

