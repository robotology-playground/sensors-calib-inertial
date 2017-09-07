function [ newOffsets ] = genNewOffsets( calibrationMap,oldOffsets,part )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

autoCalDelta = calibrationMap(['jointsOffsets_' part]);
disp(autoCalDelta);
newOffsets = round(oldOffsets - autoCalDelta,1);

end

