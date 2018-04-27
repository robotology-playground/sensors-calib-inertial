function [ nbAxes ] = getAxes( obj )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

iencs = obj.driver.viewIEncoders();
nbAxes = iencs.getAxes();

end

