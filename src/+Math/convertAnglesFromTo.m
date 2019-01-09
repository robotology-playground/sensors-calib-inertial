function [ converter ] = convertAnglesFromTo( fromUnits,toUnits )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

import System.Const;
fromToUnits = [fromUnits,toUnits];

switch num2str(fromToUnits)
    case num2str([Const.Degrees,Const.Degrees])
        converter = @(angle) angle;
    case num2str([Const.Degrees,Const.Radians])
        converter = @(angle) angle*pi/180;
    case num2str([Const.Radians,Const.Degrees])
        converter = @(angle) angle*180/pi;
    case num2str([Const.Radians,Const.Radians])
        converter = @(angle) angle;
    otherwise
        warning('Unit conversion not handled!');
end

end
