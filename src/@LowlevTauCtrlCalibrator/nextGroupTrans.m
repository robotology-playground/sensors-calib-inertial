function transition = nextGroupTrans(obj)
% Computes the transition to the next joint/motor group handling
% 
%   The joint/motor group iterator is incremented and the groups
%   list boundary is checked. If the last group has been processed,
%   the state machine ends.
%   

obj.state.currentJMcplgIdx = obj.state.currentJMcplgIdx + 1;

if obj.state.currentJMcplgIdx>numel(obj.jointMotorCouplingLabels)
    transition = 'end';
else
    transition = 'proceed';
end

end
