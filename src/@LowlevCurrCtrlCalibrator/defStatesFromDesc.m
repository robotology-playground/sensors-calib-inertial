function stateStructArray = defStatesFromDesc( statesDesc )
% Each line of 'statesDesc' is converted to a struct which fields
% are listed in the first line of 'statesDesc'.
% We get a struct array where each array element is a struct representing
% a state.

% Define list of fields
targetFields = statesDesc(1,:);

% Define the cell array of values to be converted to the struct array by
% being fold into the fields 'targetFields'
values = statesDesc(2:end,:);

% Convertion..
stateStructArray = cell2struct(values,targetFields,2);

end

