function [ table ] = convertCellArray2table( cellArray )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% convert to struct array
structArray=cellfun(@(elem) struct(elem),cellArray,'UniformOutput',true);

% convert to table
table = struct2table(structArray);

end
