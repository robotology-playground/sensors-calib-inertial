function init = loadInit(initScript)
%loadInit Builds input structure init from a script 
%   Embeds the parameters from the script 'initScript' in the init
%   structure 'init'. This is for a safer use running scripts
%   inside other scripts, avoiding variable overrides.

% run init script
run(initScript);

% get created variables list (cell array of strings)
inputVars(1,:) = who;

% embed the vaiables in the 'init' structure
for cField = inputVars
    field = cField{:};          % field string
    init.(field) = eval(field); % set field with respective variable
end

end
