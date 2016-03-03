function e = costFunctionSigmaProjOnEachLink(Dq, part, jointsToCalibrate, data, subsetVec_idx, estimator)
%COSTFUNCTIONSIGMA Summary of this function goes here
%   Detailed explanation goes here

% We defined in 'jointsNsensorsDefinitions' a segment i as a link for which 
% parent joint i and joint i+1 axis are not concurrent. For instance 'root_link',
% 'r_upper_leg', 'r_lower_leg', 'r_foot' are segments of the right leg. 'r_hip_1',
% 'r_hip2' and r_hip_3' are part of the 3 DoF hip joint.
% This function computes a sub-cost function e_k for each segment k. Each
% cost e_k is the sum of variances of all the sensor measurements projected
% on the link k frame F_k.


%% Prepare inputs for updating the kinematics information in the estimator
% 
% Compute the kinematics information necessary for the accelerometer
% sensor measurements estimation. We assume the robot root link is fixed to
% the ground (steady kart pole). We then assume to know the gravity (ground
% truth) projected on the frame (base_link) fixed to the root link. For more 
% info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions.
%
% MOVE ALL INIT VARIABLES TO PERSISTENT

% Gravity
% % % grav_idyn = iDynTree.Vector3();
% % % grav = [0.0;0.0;-9.81];
% % % grav_idyn.fromMatlab(grav);

% Get joint information: DOF
% % % dofs = estimator.model.getNrOfDOFs();

% create joint position iDynTree objects
% Note: 'JointPosDoubleArray' is a special type for future evolution which
% will handle quaternions. But for now the type has the format as 
% 'JointDOFsDoubleArray'.
% % % qi_idyn   = iDynTree.JointPosDoubleArray(dofs);
% % % fixedBasePos = iDynTree.FreeFloatingPos(estimator.model);
% % % fixedBasePos.worldBasePos() = iDynTree.Transform.Identity();

% Memory allocation for output variables
% % % traversal_Lk = iDynTree.Traversal();
% % % linkPos = iDynTree.LinkPositions();


%% Select sensors indices from iDynTree model, matching the list 'jointsToCalibrate'.
% Go through 'data.frames', 'data.parts' and 'data.labels' and build :
% - the joint vectors
% - the sensor list for the current part (part: right_leg, left_arm,...).
% This is a list of indexes, that will be later used for retrieving the
% sensor predicted measurements and the real measure from the captured data.
% % % sensorsIdxListModel = [];
% % % sensorsIdxListFile  = [];
% % % jointsIdxListModel  = [];
% % % jointsLabelIdx = 0;
% % % 
% % % for frame = 1:length(data.frames)
% % %     if strcmp(data.parts(frame),jointsToCalibrate.parts(part))
% % %         if strcmp(data.type(frame),'inertialMTB')
% % %             sensorsIdxListModel = [sensorsIdxListModel ...
% % %                 estimator.sensors.getSensorIndex(iDynTree.ACCELEROMETER,...
% % %                 char(data.frames(frame)))];
% % %             sensorsIdxListFile = [sensorsIdxListFile frame];
% % %         elseif strcmp(data.type{frame}, 'stateExt:o')
% % %             jointsLabelIdx = frame;
% % %         else
% % %             error('costFunctionSigma: wrong type ',...
% % %             'Error.\nWrong data type of sensor data. Valid types are "inertialMTB" and "stateExt:o" !!');
% % %         end
% % %     end
% % % end

% Select from label index the joints associated to the current processed part.
% % % qsRad    = ['qsRad_' data.labels{jointsLabelIdx}];
% % % dqsRad   = ['dqsRad_' data.labels{jointsLabelIdx}];
% % % d2qsRad  = ['d2qsRad_' data.labels{jointsLabelIdx}];
% % % 
% % % eval(['q0i = data.' qsRad '(:,subsetVec_idx);']);
% % % eval(['dqi = data.' dqsRad '(:,subsetVec_idx);']);
% % % eval(['d2qi = data.' d2qsRad '(:,subsetVec_idx);']);
% % % 
% % % % mapping of 'jointsToCalibrate.partJoints' into the iDynTree joint list.
% % % for joint = 1:length(jointsToCalibrate.partJoints{part})
% % %     % get joint index
% % %     jointsIdxListModel = [jointsIdxListModel...
% % %         estimator.model.getJointIndex(jointsToCalibrate.partJoints{part}{joint})];
% % % end
% % % %convert indices to matlab
% % % jointsIdxListModel = jointsIdxListModel+1;

%% compute predicted measurements
% We compute here the final cost 'e'. As it is a sum of norms, we can also
% compute it as :   v^\top \dot v    , v being a vector concatenation of
% all the components of the sum. Refer to equation(1) in https://bitbucket.org/
% gnuno/jointoffsetcalibinertialdoc/src/6c2f99f3e1be59c8021e4fc5e522fa21bdd97037/
% Papers/PaperOnOffsetsCalibration.svg?at=fix/renderingMindmaps
%
% 'costVec_Lk_ts' is an array of costs for 1 frame projection, 1 timestamp 
% and *per* sensor.
% 'costVec_Lk' is an array of costs for 1 frame projection, *per* timestamp 
% and *per* sensor.
% 'costVec' is an array of costs for *per* frame projection, *per* timestamp 
% and *per* sensor.
% % % costVec_Lk_ts = cell(length(sensorsIdxListModel),1);
% % % costVec_Lk = cell(length(subsetVec_idx),1);
% % % costVec = cell(length(jointsToCalibrate.partSegments{part}),1);
% % % 
%DEBUG
% sensMeasNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));
% sensEstNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));
% costNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));
% 
% sensMeasCell = cell(length(subsetVec_idx),length(sensorsIdxListModel));
% sensEstCell = cell(length(subsetVec_idx),length(sensorsIdxListModel));

%% Sum the costs projected on every link (we later might exclude the base
% link which doesn't have accelerometers and assume a theoretical g_0.
%
% Definition:
%
% $$e_T = \sum_{k=0}^{N} e_k$$
%
for segmentk = 1:length(jointsToCalibrate.partSegments{part})
    %% Compute the mean of measurements projected on link Lk
    %
    % Definition:
    %
    % $${}^k\mu_{g,k} = \frac{1}{PM} \sum_{p=1}^{P} \sum_{i=0}^{M} {{}^kR_{S_i}}(q_p,\Delta q) {}^{S_i}g_i(p)$$
    %
    %  Considering the following notation:
    %
    % $N$: number of links/joints in the chain, except link 0.
    % $M$: number of sensors. Each link can have several sensors attached
    % to it ($M \geq N$).
    % $S_i$: sensor $i$ frame.
    % ${}^{S_i}g_i(p)$: gravity measurement from sensor $i$, for a given
    % kinematic chain configuration $p$, expressed in the sensor $i$ frame.
    %  $G$: ground truth gravity vector.
    %  ${}^bR_a$: for any frame $a$ or $b$, rotation matrix transforming
    %  motion. vector coordinates from frame $a$ to frame $b$ (link root frames).
    %  $p$: static configuration of the kinematic chain, for a given set of
    %  measurements.
    %  $P$: number of static configurations used for capturing data.
    %  $q_p$: vector of all the joint angular positions (joint encoders reading) of the
    %  kinematic chain for a static configuration $p$.
    %  $\Delta q$: vector of encoder offsets.
    %
    
    % init the 2D array of measurements projected on link k, and their mean
% % %     Lk_sensMeasCell = cell(length(subsetVec_idx),length(sensorsIdxListModel));
% % %     mu_k = cell(length(subsetVec_idx),1);
    
    % set 'Lk' as the traversal base to be used at current
    % iteration
% % %     Lk = estimator.model.getLinkIndex(jointsToCalibrate.partSegments{part}{segmentk});
% % %     estimator.model.computeFullTreeTraversal(traversal_Lk, Lk);
    
    for ts = 1:length(subsetVec_idx)
        % Fill the full floating base joint positions configuration
% % %         qisRobotDOF = zeros(dofs,1); qisRobotDOF(jointsIdxListModel,1) = q0i(:,ts) + Dq;
% % %         qi_idyn.fromMatlab(qisRobotDOF);
% % %         fixedBasePos.jointPos() = qi_idyn;
        
        % Project on link frame Lk all measurements from each sensor referenced in
        % 'sensorsIdxList'and compute the mean.
        for acci = 1:length(sensorsIdxListModel)
% % %             % get sensor handle
% % %             sensor = estimator.sensors.getSensor(iDynTree.ACCELEROMETER,sensorsIdxListModel(acci));
% % %             % get the sensor to link i transform Li_H_acci
% % %             Li_H_acci = sensor.getLinkSensorTransform();
% % %             % get the projection link k to link i transform Lk_H_Li
% % %             iDynTree.ForwardPositionKinematics(estimator.model, traversal_Lk, ...
% % %                                                fixedBasePos, linkPos);
% % %             Li = sensor.getParentLinkIndex();
% % %             Lk_H_Li = linkPos(Li);
% % %             % get measurement table ys_xxx_acc [3xnSamples] from captured data,
% % %             % and then select the sample 's' (<=> timestamp).
% % %             ys   = ['ys_' data.labels{sensorsIdxListFile(acci)}];
% % %             eval(['sensMeas = data.' ys '(:,ts);']);
% % %             % project the measurement in link Lk frame and store it for
% % %             % later computing the variances
% % %             Lk_sensMeasCell{ts,acci} = Lk_H_Li * Li_H_acci * sensMeas;
        end
% % %         % compute the mean
% % %         mu_k{ts} = mean(cell2mat(Lk_sensMeasCell{ts,:}),2);
    end
    
    %% Compute the variances of measurements projected on link Lk
    %
    % Definition:
    %
    % $$e_k = \sum_{p=1}^{P} \sum_{i=0}^{M} \Vert {}^kR_{S_i}(q_p,\Delta q) {}^{S_i}g_i(p) - {{}^k\mu_{g,k}} \Vert^2$$
    %
    % Considering the same previous notation, and the following additions:
    % $k$: link frame where we project the measurements
    % $N$: total number of links
    %
% % %     for ts = 1:length(subsetVec_idx)
% % % 
% % %         % Fill iDynTree joint vectors.
% % %         % Warning!! iDynTree takes in input **radians** based units,
% % %         % while the iCub port stream **degrees** based units.
% % %         qisRobotDOF = zeros(dofs,1); qisRobotDOF(jointsIdxListModel,1) = q0i(:,ts) + Dq;
% % %         qi_idyn.fromMatlab(qisRobotDOF);
% % %         fixedBasePos.jointPos() = qi_idyn;
% % %         
% % %         % Project on link frame Lk all measurements from each sensor referenced in
% % %         % 'sensorsIdxList'and compute the variance w.r.t. the previously computed mean.
% % %         % Formulate computation as variance = diff' * diff.
% % %         for acci = 1:length(sensorsIdxListModel)
% % %             % get previously computed measurement projected on frame link k
% % % 
% % %             % compute the cost for 1 sensor / 1 timestamp, usig previously
% % %             % computed measurement (ts,acci) and mean(ts), projected on
% % %             % frame link k
% % %             costVec_Lk_ts{acci} = (Lk_sensMeasCell{ts,acci} - mu_k{ts});
% % %             %DEBUG
% % % %             sensMeasNormMat(ts,acci) = norm(sensMeas,2);
% % % %             sensEstNormMat(ts,acci) = norm(sensEst,2);
% % % %             costNormMat(ts,acci) = norm(costVec_Lk_ts{acci},2);
% % % %             sensMeasCell{ts,acci} = sensMeas';
% % % %             sensEstCell{ts,acci} = sensEst';
% % %         end
% % % 
% % %         costVec_Lk{ts} = cell2mat(costVec_Lk_ts);
% % %     end
% % %     costVec{Lk} = cell2mat(costVec_Lk);
end

% Final cost = norm of 'costVec'
% % % costVecMat = cell2mat(costVec);
% % % e = costVecMat'*costVecMat;


% %% DEBUG: plot debug data
% persistent scrsz;
% if isempty(scrsz)
%     scrsz = get(0,'ScreenSize');
% end
% persistent fig1;
% if isempty(fig1)
%     fig1 = figure('Name', '||sensor meas|| (red) & ||sensor estim|| (blue)');
% end
% persistent fig2;
% if isempty(fig2)
%     fig2 = figure('Name', '||sens_meas - sens_est|| & mean of norms');
% end
% persistent fig3;
% if isempty(fig3)
%     fig3 = figure('Name', '3D vector sensor_meas');
% end
% persistent fig4;
% if isempty(fig4)
%     fig4 = figure('Name', '3D vector sensor_est');
% end
% 
% figure(fig1);
% plot(sensMeasNormMat,'r');
% hold on;
% plot(sensEstNormMat,'b');
% hold off;
% 
% figure(fig2);
% plot(costNormMat,'g');
% hold on;
% plot(mean(costNormMat,2),'m');
% hold off;
% 
% %% DEBUG: plot gravity as 3D vector
% origin=zeros(length(subsetVec_idx),3);
% 
% for acc_i = 1:length(sensorsIdxListModel)
%     figure(fig3);
%     Vmeas=cell2mat(sensMeasCell(:,acc_i));
%     quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,2));
%     axis equal;
%     axis vis3d;
%     figure(fig4);
%     Vest=cell2mat(sensEstCell(:,acc_i));
%     quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,2));
%     axis equal;
%     axis vis3d;
%     
%     pause;
% end


end

