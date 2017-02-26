function seqParams = setValFromGrid(gridParams,acqVel,transVel,labels)

% parse the grid parameters (creates vars 'part1','jointIdx1','part2'...)
q1params = cell2struct(gridParams(2,:),gridParams(1,:),2);
q2params = cell2struct(gridParams(3,:),gridParams(1,:),2);
part = labels{3,ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'pos')};
q1params.part = part;
q2params.part = part;

% create sequence where q1 spans once from qmin1 to qmax2 step by step, and
% q2 spans its range in a continuous way.
[seqA.q1,seqA.q2,seqA.dq1,seqA.dq2,seqA.measTag] = ...
    buildGrid(q1params,q2params,acqVel,transVel);

% create sequence where q1 and q2 now have their roles inverted
[seqB.q1,seqB.q2,seqB.dq1,seqB.dq2,seqB.measTag] = ...
    buildGrid(q2params,q1params,acqVel,transVel);

% convatenate...
[q1,q2,dq1,dq2,measTag] = structfun(...
    @(vecA,vecB) [vecA;vecB],...
    seqA,seqB,...
    'UniformOutput',true);

% Reshape the data for setting ['ctrl','pos','<part>'] and ['ctrl','vel','<part>']
% colums of 'seqParams':
% - first init to all zeros
jointsList = RobotModel.jointsListFromPart(part);
ctrlPos = zeros(length(q1),length(jointsList));
ctrlVel = ctrlPos;
% - select columns for the controlled joints
colq1 = ismember(jointsList,q1params.joint);
colq2 = ismember(jointsList,q2params.joint);
% - set values the controlled joints
ctrlPos(colq1) = q1; ctrlVel(:,colq1) = dq1;
ctrlPos(colq2) = q2; ctrlVel(:,colq2) = dq2;
% - reshape as a list and set to 'seqParams'. We don't assume what the
% 'pos','vel' labels order is in 'labels' cell array.
posCols = ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'pos');
seqParams(:,posCols) = num2cell(ctrlPos,2);
velCols = ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'vel');
seqParams(:,velCols) = num2cell(ctrlVel,2);

% Set measurement tags
measCols = ismember(labels(1,:),'meas');
seqParams(:,measCols) = repmat(num2cell(measTag,2),1,sum(measCols));

end
