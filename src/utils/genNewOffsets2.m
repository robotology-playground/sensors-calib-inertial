function [ newOffsets ] = genNewOffsets2( encRead,encDes,oldOffsets )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

delta = encRead - encDes;
newOffsets = round(oldOffsets + delta,1);

end

