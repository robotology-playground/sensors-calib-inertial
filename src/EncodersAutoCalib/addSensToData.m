function [ data ] = addSensToData( data, part, label, ndof, index, type, visualize)
%ADDSENSTODATA Add a sensor to the data structure
currSize = length(data.parts);
data.parts{currSize+1} = part;
data.labels{currSize+1} = label;
data.ndof{currSize+1} = ndof;
data.index{currSize+1} = index;
data.type{currSize+1} = type;
data.visualize{currSize+1} = visualize;

end

