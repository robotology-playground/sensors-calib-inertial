function propList = getPropList(obj,inputPropsStruct,outputPropName)
%getPropList Retrieve the 'outputPropName' property of elements matching input
%            properties specified in 'inputPropsStruct'.
%   
%   This method finds the elements of the database matching the properties
%   specified as input, in 'inputPropsStruct'.
%   
%   inputPropsStruct : defines the input properties to match.
%   outputPropName   : returned property of the matching database element.
%   
%   Note: 'inputPropsStruct' can have several formats.
%   inputPropsStruct.queryFormat = <format id> = [0..n]
%   (current n=2)
%   inputPropsStruct.data =
%   (n = 0) --> {}
%               The query targets all elements.
%   
%   (n = 1) --> {'<prop name1>',<prop value1>;...
%                '<prop name2>',<prop value2>;...
%                ..
%                '<prop nameK>',<prop valueK>}
%               All listed properties have to match (AND of all lines)
%   
%   (n = 2) --> {'<prop name>',<list of prop values>}}
%               A list of matching elements is returned, 1 <outputPropName>
%               value for each element matching 1 input prop value.
%   
%   The method always returns a list, whatever the format of the listed
%   elements type/class (doubles, strings, etc).
%

end
