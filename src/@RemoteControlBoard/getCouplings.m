function [ couplingList ] = getCouplings( obj )
%This method retrieves the coupling parameters through the IRemoteVariables debug interface
%   For each set of actually coupled joints, a structure is built, holding:
%   - coupling.invT : the coupling matrix 3x3 or just the integer 1
%   - coupling.coupledJoints : ordered list of coupled joint names
%   - coupling.coupledMotors : ordered list of coupled motor names
%
% where invT defined as : $$ \dot{m} = T^{-1} \dot{q} $$

% We get the raw coupling matrix.
rawCoupling = obj.getRawCoupling();
% ... the joint names.
joints = obj.getAxesNames();
% ... the motor names. We assume there is an equal number of joints and
% motors. Format of motor name: m_<part>_<idx>
motors = cellfun(@(idx) ['m_' obj.part '_' num2str(idx)],num2cell(1:numel(joints)),'UniformOutput',false);

% This matrix has several joint/motor pair couplings as well as
% standalone joint/motor pairs.
% We wish to identify the couplings and the standalone degrees of freedom

%% Set apart the real couplings from the standalone joints
%  We model the coupling information as a bipartite graph
%  (https://en.wikipedia.org/wiki/Bipartite_graph).
%  Identifying the couplings is then trivial.

% Define the graph 'G' using an weighted adjacency matrix. An element Aij of
% such matrix is zero when there is no edge from vertex i to vertex j, and
% one when there is one:
% (https://en.wikipedia.org/wiki/Adjacency_matrix#Adjacency_matrix_of_a_bipartite_graph):
% $$
% A = 
% \begin{bmatrix}
% 0_{m,m} & B_{m,q} \\
% B_{q,m}^{\top} & 0_{q,q}
% \end{bmatrix}
% $$
% 
% Where 'm' is the number of motors and 'q' the number of joints. In our
% case, we always have m=q. We define:
% B = T_raw
B = (rawCoupling ~= 0);
A = [zeros(size(B)) , B ; B' , zeros(size(B))];
G = graph(A,[motors,joints]); % create a graph from adjacence matrix and node names

% Use the graph methods for identifying the couplings. Each coupling is a
% connected component.
couplings = G.conncomp('OutputForm','cell');

% Now 'couplings' is a cell array where each cell stands for a couplings
% and contains the list of joints and motors names in that couling.
% Create the respective coupling objects.
couplingList = cell(1,numel(couplings));
for idx = 1:numel(couplings)
    % coupled joints
    jointsBitmap = ismember(joints,couplings{idx});
    cpldJoints = joints(jointsBitmap);
    % coupled motors
    motorsBitmap = ismember(motors,couplings{idx});
    cpldMotors = motors(motorsBitmap);
    % coupling matrix
    invT = rawCoupling(motorsBitmap,jointsBitmap);
    
    % create the coupling object
    couplingList{idx} = JointMotorCoupling(invT,cpldJoints,cpldMotors,[],obj.part);
end

% boolRawCoupling = (rawCoupling ~= 0);
% 
% % split coupled joints and motors from standalone ones
% couplingIdx = 1;
% jointsIdxes = 1:size(boolRawCoupling,2);
% motorsIdxes = 1:size(boolRawCoupling,1);
% coupledJointsIdxes = [];
% coupledMotorsIdxes = [];
% 
% while size(boolRawCoupling,2)>0
%     % add joint from first column to the indexed coupling
%     coupledJointsIdxes = [coupledJointsIdxes jointsIdxes(1)];
%     % add motors coupled with that same joint
%     coupledMotorsIdxes = [coupledMotorsIdxes motorsIdxes(boolRawCoupling(:,1))];
%     ...
% end
% 
% couplingList = JointMotorCoupling();

end
