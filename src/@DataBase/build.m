function success = build(obj)
%build Creates the mappings between properties and keys, as well as the
%accessors.

%% check structure consistency before building database
% all property names or keys are strings
if class(obj.propNameList{1})~='char'
    error('Property names list should all be char type.');
end
% keys list is a subset of property names list
if ~all(ismember(obj.propKeyList,obj.propNameList))
    error('One of the keys is not present in the properties names list.');
end
% 
if ~all(size(obj.propNameList)' == [1 size(obj.propValueList,2)]')
    error('property names and property values lists sizes don''t match');
end


%% build database

obj.ready = true;
success = true;

end
