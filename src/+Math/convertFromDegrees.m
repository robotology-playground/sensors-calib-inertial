function [ converter ] = convertFromDegrees( toUnits )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

switch toUnits
    case System.Const.Degrees
        converter = @(angle) angle;
    case System.Const.Radians
        converter = @(angle) angle*pi/180;
    otherwise
        warning('Unit conversion not handled!');
end

end
