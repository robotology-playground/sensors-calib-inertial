function success = setPropList( obj,...
    queryKeyName,queryKeyValues,...
    propNameToSet,propValuesToSet )
%setPropList Select elements which <inputKeyName> is among <inputKeyValues> and set
%            the <propNameToSet> respective properties to <propValuesToSet> values.
%   
%   inputKeyName   : key property name (type) where to search for the values.
%   
%   inputKeyValues : list of key property values to match.
%   
%   propNameToSet  : property (of the matching database element) to set.
%   
%   propValuesToSet: list of values to set to the matching element's <propNameToSet>
%                    property.
%

% build query (input properties to match)
inputQuery.format = 2;
inputQuery.data = {queryKeyName,queryKeyValues};

% get line Idx of the queried element
elemRowIdxList = obj.getElemRowIdxList(inputQuery);

% get the output property column
propNameCol = obj.name2colIdx(propNameToSet);

% set queried value
obj.propValueList(elemRowIdxList,propNameCol) = propValuesToSet;

success = true;

end
