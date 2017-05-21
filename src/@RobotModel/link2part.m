function part = link2part( link )
%link2part Get the part (left_leg,right_arm) the link belongs to

arm_links = @(side) {...
    [side '_shoulder_1'],[side '_shoulder_2'],[side '_shoulder_3'],...
    [side '_upper_arm'],[side '_elbow_1'],[side '_forearm'],...
    [side '_wrist_1'],[side '_hand']};
leg_links = @(side) {...
    [side '_hip_1'],[side '_hip_2'],[side '_hip_3'],...
    [side '_upper_leg'],[side '_lower_leg'],...
    [side '_ankle_1'],[side '_ankle_2'],[side '_foot']};
torso_links = {'root_link','torso_1','torso_2','chest'};
head_links = {'neck_1','neck_2','head'};

switch link
    case arm_links('l')
        part = 'left_arm';
    case arm_links('r')
        part = 'right_arm';
    case leg_links('l')
        part = 'left_leg';
    case leg_links('r')
        part = 'right_leg';
    case torso_links
        part = 'torso';
    case head_links
        part = 'head';
    otherwise
        part = 'unknown';
end

end

