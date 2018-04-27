function propList = getMultiPropList(obj,queryPropsStruct,outputPropNameList)
%Retrieve the 'outputPropNameList' properties of elements matching input
%            properties specified in 'queryPropsStruct'.
%   
%   This method finds the elements of the database matching the properties
%   specified as input, in 'queryPropsStruct'.
%   
%   queryPropsStruct   : defines the input properties to match.
%   outputPropNameList : returned properties of the matching database element.
%   
%   Note: 'queryPropsStruct' can have several formats. Refer to method
%   getPropList() description.
%   

% get line Idx of the queried element
elemRowIdxList = obj.getElemRowIdxList(queryPropsStruct);

% get the output property column
outputPropNameCols = cell2mat(obj.name2colIdx.values(outputPropNameList));

% get queried value
propList = obj.propValueList(elemRowIdxList,outputPropNameCols);

end
