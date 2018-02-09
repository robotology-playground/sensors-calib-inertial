function transition = nextGroupTrans(obj)
% Computes the transition to the next joint/motor group handling
% 
%   The joint/motor group iterator is incremented and the groups
%   list boundary is checked. If the last group has been processed,
%   the state machine ends.
%   

obj.state.currentMotorIdx = obj.state.currentMotorIdx + 1;

if obj.state.currentMotorIdx>numel(obj.expddMotorList)
    transition = 'end';
else
    transition = 'proceed';
end

end
