function [ converter ] = convertFromRadians( toUnits )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

switch toUnits
    case System.Const.Degrees
        converter = @(angle) angle*180/pi;
    case System.Const.Radians
        converter = @(angle) angle;
    otherwise
        warning('Unit conversion not handled!');
end

end
