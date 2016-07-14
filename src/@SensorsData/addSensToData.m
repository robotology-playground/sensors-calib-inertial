function addSensToData(obj, part, frame, label, ndof, index, type, calib, visualize)

%ADDSENSTODATA Add a sensor to the data structure
currSize = length(obj.parts);
obj.parts{currSize+1} = part;
obj.frames{currSize+1} = frame;
obj.labels{currSize+1} = label;
obj.ndof{currSize+1} = ndof;
obj.index{currSize+1} = index;
obj.type{currSize+1} = type;
obj.calib{currSize+1} = calib;
obj.visualize{currSize+1} = visualize;

end

