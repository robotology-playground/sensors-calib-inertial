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
if ~all(size(obj.propNameList)' == [1 size(obj.propValueList,2)]')
    error('property names and property values lists sizes mismatch');
end

obj.nbNames = length(obj.propNameList);
obj.nbElems = size(obj.propValueList,1);

%% build database

% map the property names to column indexes
obj.name2colIdx = containers.Map(obj.propNameList,num2cell(1:obj.nbNames));

% init the list of func handles mapping the property value to the row idx
obj.name2rowIdxHandleList = cell(size(obj.propNameList));

% Define the mapper functions. These mapper functions return 2 quantities
% as the function 'ismember()':
% 
% [lIa,locB] = mapperFuncH(A,B)
% 
% 'lIa': array of the same size as A containing true where the elements 
% of A are in B and false otherwise.
% 'locB': array containing the absolute index in B for each element in A
% which is a member of B and 0 if A is not a member of B.
% For objects, we only support querying one at a time. Therefore, A is a
% scalar, so 'lIa' will have only 1 element = true (all objects are unique),
% and the respective element in 'locB' is set to the only index of A, i.e. 1.
% So in this particular case 'lIa'='locB'. This is implemented through the
% 'deal' function.
% char   : mapperFuncH = @(queryList,dBaseList) ismember(dBaseList,queryList);
% numeric: mapperFuncH = @(queryList,dBaseList) ismember(cell2mat(dBaseList),cell2mat(queryList));
% object : mapperFuncH = @(queryElem,dBaseList) deal(eq(queryElem,[dBaseList{:}]));

% == Note ==
% [bitmap,listk]=ismember(database,queryList).
% This tells us which elements of the database are present in the query
% list, and the respective indexes in the query list.


% go across the prop name list and set the function handles according to
% the prop type.
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
        mapperFuncH = @(queryElem) deal(eq(queryElem{:},[dBaseList{:}]));
    else % default
        mapperFuncH = @(queryList) ismember(dBaseList,queryList);
    end
    
    % set the list of handles
    obj.name2rowIdxHandleList{valueIdx} = mapperFuncH;
end

% %=== keys special use case ===========: TO BE FIXED AND UNCOMMENTED
% % get the indexes of the key props and update the respective func handles
% keyIdxes = cell2mat(obj.name2colIdx.values(obj.propKeyList));
% % map the keys to line indexes and set the key map handles
% for keyIdx = keyIdxes(:)'
%     % get the values for current key
%     values = obj.propValueList(:,keyIdx);
%     % build the mapping
%     key2linIdx = containers.Map(values,num2cell(1:obj.nbElems));
%     % set mapping handle in the list
%     obj.name2rowIdxHandleList{keyIdx} = @(queryList) cell2mat(key2linIdx.values(queryList));
% end

% update database state
obj.ready = true;
success = true;

end
