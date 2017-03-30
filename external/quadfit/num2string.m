function str = num2string(coef,cformat)
% Convert a numeric value to a string in the specified format.

% Copyright 2009-2011 Levente Hunyadi

validateattributes(coef, {'numeric'}, {'scalar'});
if nargin >= 2
    validateattributes(cformat, {'char'}, {'vector'});
else
    cformat = get(0,'format');
end
cformat = lower(cformat);

% get the window format
switch cformat
    case 'short'  % fixed-point format with 5 digits
        str = sprintf('%6f', coef);
    case 'shorte'  % floating-point format with 5 digits
        str = sprintf('%.4e', coef);
    case 'shortg'  % fixed- or floating-point format displaying as many significant figures as possible with 5 digits
        str = sprintf('%.5g', coef);
    case 'long'  % scaled fixed-point format with 15 digits
        str = sprintf('%16f', coef);
    case 'longe'  % floating-point format with 15 digits
        str = sprintf('%.14e', coef);
    case 'longg'  % fixed- or floating-point format displaying as many significant figures as possible with 15 digits
        str = sprintf('%.15g', coef);
    case {'rat','rational'}
        str = rats(coef,15);
        str = strtrim(str);  % drop the leading and trailing blanks
    otherwise
        str = num2str(coef);
end
