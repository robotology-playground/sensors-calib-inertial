function [ sens ] = addSensToSens( sens, part, label, ndof, type, transform)
%ADDSENSTODATA Add a sensor to the data structure
currSize = length(sens.parts);
sens.parts{currSize+1} = part;
sens.labels{currSize+1} = label;
sens.ndof{currSize+1} = ndof;
sens.type{currSize+1} = type;
sens.transform{currSize+1} = transform;

end

