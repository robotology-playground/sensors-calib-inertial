function concatMap( aMap,addedMap )
%Stores in 'aMap' the elements of 'addedMap'
%   Detailed explanation goes here

for key = addedMap.keys
    aMap(key{1}) = addedMap(key{1});
end

end

