function transition = promptUser( obj )
% Prompts the user for restart, proceed, skip or abort
%   Displays the following text depending on the current state:
%
%   (R)estart / (P)roceed / (S)kip / (A)bort? [P]:
%
%   Restart: restarts the current step, back to the data acquisition of the
%            current motor group.
%   Proceed: proceeds to the next step (data acq -> model fitting
%   Skip   : skips the whole step up to the next motor group.
%
%   If user entry is not among the proposed ones, the prompt is displayed
%   again.
%

transition = 'ABORT';
validInput = false;

% loop until the user provides a valid input
while ~validInput
    reply = input('(r)estart / (p)roceed / (s)kip / (e)nd / (a)bort? [p]:','s');
    
    if isempty(reply)
        reply = 'p';
    end
    
    validInput = true;
    switch reply
        case 'r'
            transition = 'restart';
        case 'p'
            transition = 'proceed';
        case 's'
            transition = 'skip';
        case 'e'
            transition = 'end';
        case 'a'
            transition = 'ABORT';
        otherwise
            validInput = false;
    end
end

end
