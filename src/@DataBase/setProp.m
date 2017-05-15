function success = setProp( obj,inputPropsStruct,inputPropName,propValueToSet )
%setProp     Set to 'propValueToSet' the 'inputPropName' property of elements matching
%            input properties specified in 'inputPropsStruct'.
%   
%   This method finds the elements of the database matching the properties
%   specified as input, in 'inputPropsStruct'.
%   
%   inputPropsStruct : defines the input properties to match.
%   inputPropName    : property (of the matching database element) to set.
%   propValueToSet   : value to set.
%   
%   Note: 'inputPropsStruct' can have several formats (sam as for
%   'getPropList' function).
%   inputPropsStruct.queryFormat = <format id> = [0..n]
%   (current n=2)
%   inputPropsStruct.data --> refer to 'getPropList' function.
%

end
