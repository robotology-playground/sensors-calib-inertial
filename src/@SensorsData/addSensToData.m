function addSensToData(obj, part, frame, label, sensorAct, isInverted, ndof, index, type, gain, visualize)

%ADDSENSTODATA Add a sensor to the data structure
currSize = length(obj.parts);
obj.parts{currSize+1} = part;
obj.frames{currSize+1} = frame;
obj.labels{currSize+1} = label;
obj.sensorAct{currSize+1} = sensorAct;
obj.isInverted{currSize+1} = isInverted;
obj.ndof{currSize+1} = ndof;
obj.index{currSize+1} = index;
obj.type{currSize+1} = type;
obj.gain{currSize+1} = gain;
obj.visualize{currSize+1} = visualize;

end

