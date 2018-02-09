function success = build(obj)
%build Creates the mappings between properties and keys, as well as the
%accessors.

%% check structure consistency before building database
% all property names or keys are char vectors
if ~iscellstr(obj.propNameList)
    error('Property names list should all be char type.');
end
% keys list is a subset of property names list
if ~all(ismember(obj.propKeyList,obj.propNameList))
    error('One of the keys is not present in the properties names list.');
end
% size mismatch
if ~all(size(obj.propNameList) == [1 size(obj.propValueList,2)])
    error('property names and property values lists sizes mismatch');
end

obj.nbNames = length(obj.propNameList);
obj.nbElems = size(obj.propValueList,1);

%% build database

% map the property names to column indexes
obj.name2colIdx = containers.Map(obj.propNameList,num2cell(1:obj.nbNames));

% init the list of func handles mapping the property value to the row idx
obj.name2rowIdxHandleList = cell(size(obj.propNameList));

% Define the mapper functions. We first define a mapper function
% 'isMemberAllT()' returning 2 quantities as the function 'ismember()':
% 
% [isAinB,locInB] = isMemberAllT(A,B)
% 
% As for 'ismember', we have...
% 'isAinB': array of the same size as A containing [true] where the elements 
% of A are in B and [false] otherwise.
% 'locInB': array containing the absolute index in B for each element in A
% which is a member of B and 0 if A is not a member of B.
% 
% The function works exactly like 'ismember()' except that it supports the
% types 'char', 'double' (numeric) and 'object'. For objects, we only
% support querying one at a time, so B will hold a single element in that
% case. In general, A is the list where to find the elements ('dBaseList')
% and B the list of elements to locate ('queryList'). We would then define
% isMemberAllT(A,B) depending on the type of the elements in 'dBaseList':
% 
% char   : isMemberAllT = @(dBaseList,queryList) ismember(dBaseList,queryList);
% numeric: isMemberAllT = @(dBaseList,queryList) ismember(cell2mat(dBaseList),cell2mat(queryList));
% object : isMemberAllT = @(dBaseList,queryElem) eq(queryElem,[dBaseList{:}]);
% 
% In fine, a mapping function is defined for each property name (column list
% 'dBaseList') and includes the 'dBaseList' in its definition:
% 
% mapperFuncH = @(queryList) isMemberAllT(dBaseList,queryList)
% 


% go across the first line of the prop values list and set the function
% handles according to the elements type.
for propValue = [obj.propValueList(1,:);num2cell(1:obj.nbNames)]
    % extract current prop value, and current index
    value = propValue{1}; valueIdx = propValue{2};
    dBaseList = obj.propValueList(:,valueIdx);
    % select mapper func handle according to the type
    if ischar(value)
        mapperFuncH = @(queryList) ismember(dBaseList,queryList);
    elseif isnumeric(value)
        mapperFuncH = @(queryList) ismember(cell2mat(dBaseList),cell2mat(queryList));
    elseif isobject(value)
        mapperFuncH = @(queryElem) eq(queryElem{:},[dBaseList{:}]);
    else % default
        mapperFuncH = @(queryList) ismember(dBaseList,queryList);
    end
    
    % set the list of handles
    obj.name2rowIdxHandleList{valueIdx} = mapperFuncH;
end

% %=== keys special use case ===========: TO BE CHECKED (order of selected lines)
% % get the indexes of the key props and update the respective func handles
% keyIdxes = cell2mat(obj.name2colIdx.values(obj.propKeyList));
% % map the keys to line indexes and set the key map handles
% for keyIdx = keyIdxes(:)'
%     % get the values for current key
%     values = obj.propValueList(:,keyIdx);
%     % build the mapping
%     key2linIdx = containers.Map(values,num2cell(1:obj.nbElems));
%     % set mapping handle in the list
%     mapperFuncH = @(queryList) cell2mat(key2linIdx.values(queryList));
%     obj.name2rowIdxHandleList{keyIdx} = mapperFuncH;
% end

% update database state
obj.ready = true;
success = true;

end
