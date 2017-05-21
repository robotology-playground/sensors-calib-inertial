function elemRowIdxList = getElemRowIdxList( obj,queryPropsStruct )
%getElemList Retrieve handles pointing to elements which properties match the
%            input parameters 'queryPropsStruct'.
%   
%   This method finds the elements of the database matching the properties
%   specified as input, in 'queryPropsStruct'.
%   
%   queryPropsStruct : defines the input properties to match.
%   elemRowIdxList   : returned index list of the matching database element.
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
%   The method always returns a list, whatever the format of the listed
%   elements type/class (doubles, strings, etc).
%

% the final returned index list is a subset of the full index list
fullIdxList = 1:obj.nbElems;

switch queryPropsStruct.format
    case 0
        elemRowIdxList = fullIdxList;
        
    case 1
        % init bitmap element selection table N x K where N is the number
        % of elements (rows) of the database, and is K the number of requested
        % property names.
        nbQueriedProps = size(queryPropsStruct.data,1);
        inBitmap = zeros(obj.nbElems,nbQueriedProps);
        
        % for each property to match, select the database column
        for propNameValueIdx = [queryPropsStruct.data';num2cell(1:nbQueriedProps)]
            % current iterator triplet has the property information:
            % propNameValueIdx = [<propName>;
            %                     <propValue>;
            %                     <propIdx>]
            
            % select the property column where to run the search
            queryPropNameIdx = obj.name2colIdx(propNameValueIdx{1});
            
            % get the matching values by using the mapper function for that
            % respective column
            mapperFuncH = obj.name2rowIdxHandleList{queryPropNameIdx};
            
            % call mapperFuncH(<queryList)
            inBitmap(:,propNameValueIdx{3}) = mapperFuncH(propNameValueIdx(2));
        end
        
        % combine the results (AND) of all processed columns
        elemRowIdxList = fullIdxList(all(inBitmap,2));
        
    case 2  
        % select the property column where to run the search
        queryPropNameIdx = obj.name2colIdx(queryPropsStruct.data{1});
        
        % get the matching values by using the mapper function for that
        % respective column
        mapperFuncH = obj.name2rowIdxHandleList{queryPropNameIdx};
        
        % call mapperfunc(<queryList,<dataBaseList>)
        [inBitmap,idxList] = mapperFuncH(queryPropsStruct.data{2});
        
        % the elements in 'inBitmap' and 'idxList' are ordered as the
        % elements in the database column (obj.propValueList(:,i)). We
        % need to reorder them following the elements in the query list
        % 'queryPropsStruct.data{2}':
        % => elemRowIdxList(idxList) = fullIdxList
        % idxList contains zeros (elements of the database not present in
        % the query list), so we filter them using 'inBitmap'.
        elemRowIdxList(idxList(inBitmap)) = fullIdxList(inBitmap);
        
    otherwise
        error('Unknown query format!')
end

end

% === Notes on the search methods =========================================
% 
%   'ismember(A,B)' supports the following classes for A and B (A and B
% being of same class):
% - logical, char, all numeric classes (may combine with double arrays)
% - cell arrays of strings (may combine with char arrays)
% - 'rows' option is not supported for cell arrays
% - objects with methods SORT
% So that function won't work for cell arrays of numeric classes.
% For using 'ismember', we have to convert A and B elements to arrays of
% strings on the first hand. We prefer not to do that conversion when
% building the database to avoid back and forth conversions and potential
% loss of information or irreversible conversions. Conversion would then be
% done only to a temporary discardable format right before call to
% 'ismember'. An alternative solution is to convert the cell array to a
% matrix of numeric classes before calling 'ismember'.
%   'isequal' returns logical 1 (TRUE) if arrays A and B are the same size
% and contain the same values, and logical 0 (FALSE) otherwise. So this
% solution is dropped.
%   For cell arrays of numeric classes, 'A == B' does element by element
% comparisons between A and B. If A is a vector, its size has to be
% compatible with B's. '==' then tries to match the same order of placement of
% elements in A and B, while 'ismember' doesn't. Example:
% >> eq([1,2],[1,2;3,4])
% ans =
%   1   1
%   0   0
% 
% >> eq([1,2],[2,1;3,4])
% ans =
%   0   0
%   0   0
% 
% === Retained solution ===
% 
% 1) For matching k values of a single field name (query format 2), we shall
% identify the fieldname index through a map container, then use 'ismember'
% on the selected column:
% - In the case of numeric classes, we do a prior conversion of the list to a
% matrix ('cell2mat').
% - In the case of objects, use the '==' operator.
% 
% 2) For matching values accross several field names (query format 1), we shall
% use 'ismember' to identify the fieldnames, concatenate the selected columns
% into a merged single one, then use 'ismember' to match the values with the
% query. The query itself shall be a concatenation of all the requested values.
% 
% 3) [bitmap,listk]=ismember(A,B) returns in listk the lowest absolute index in
% B for each element in A which is a member of B and 0 if there is no such index.
% But we need ALL occurences of queryList elements in the database
% elements, we need to do [bitmap,listk]=ismember(database,queryList).
% This tells us which elements of the database are present in the query
% list, and the respective indexes in the query list.

