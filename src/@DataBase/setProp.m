function success = setProp( obj,queryPropsStruct,propNameToSet,propValueToSet )
%setProp     Set to 'propValueToSet' the 'propNameToSet' property of elements matching
%            input properties specified in 'queryPropsStruct'.
%   
%   This method finds the elements of the database matching the properties
%   specified as input, in 'queryPropsStruct'.
%   
%   queryPropsStruct : defines the input properties to match.
%   propNameToSet    : property (of the matching database element) to set.
%   propValueToSet   : value to set.
%   
%   Note: 'queryPropsStruct' can have several formats.
%   queryPropsStruct.format = <format id> = [0..n]
%   (current n=2)
%   queryPropsStruct.data =
%   (n = 0) --> {}
%               The query targets all elements.
%   
%   (n = 1) --> {'<prop name1>',<prop value1>;...
%                '<prop name2>',<prop value2>;...
%                ..
%                '<prop nameK>',<prop valueK>}
%               All listed properties have to match (AND of all lines)
%   
%   (n = 2) --> {'<prop name>',{<list of prop values>}}
%               A list of matching elements is returned, 1 <outputPropName>
%               value for each element matching 1 input prop value.
%   

% get line Idx of the queried element
elemRowIdxList = obj.getElemRowIdxList(queryPropsStruct);

% get the output property column
propNameCol = obj.name2colIdx(propNameToSet);

% set queried value
obj.propValueList(elemRowIdxList,propNameCol) = {propValueToSet};

success = true;

end
