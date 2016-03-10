function [ data ] = addSensToData( data, part, frame, label, sensorAct, isInverted, ndof, index, type, visualize)
%ADDSENSTODATA Add a sensor to the data structure
currSize = length(data.parts);
data.parts{currSize+1} = part;
data.frames{currSize+1} = frame;
data.labels{currSize+1} = label;
data.sensorAct{currSize+1} = sensorAct;
data.isInverted{currSize+1} = isInverted;
data.ndof{currSize+1} = ndof;
data.index{currSize+1} = index;
data.type{currSize+1} = type;
data.visualize{currSize+1} = visualize;

end

