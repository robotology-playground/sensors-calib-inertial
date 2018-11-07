function [readEncAccs] = getEncoderAccelerations(obj,jointsIdxList)

obj.yarpVector.zero();
obj.iencs.getEncoderAccelerations(obj.yarpVector.data());
readAllEncAccs=obj.yarpVector.toMatlab();
readEncAccs = readAllEncAccs(jointsIdxList);

end
