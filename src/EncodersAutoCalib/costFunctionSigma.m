function e = costFunctionSigma(Dq, part, jointsToCalibrate, data, subsetVec_idx, estimator, optimFunction)
%COSTFUNCTIONSIGMA Summary of this function goes here
%   Detailed explanation goes here

%% Prepare inputs for updating the kinematics information in the estimator
% 
% Compute the kinematics information necessary for the accelerometer
% sensor measurements estimation. We assume the robot root link is fixed to
% the ground (steady kart pole). We then assume to know the gravity (ground
% truth) projected on the frame (base_link) fixed to the root link. For more 
% info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions.
%
% MOVE ALL INIT VARIABLES TO PERSISTENT

% correction for MTB mounted upside-down
global real_R_model;
global mtbSensorAct_left_leg;

% Gravity
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);

% Get joint information: DOF
dofs = estimator.model().getNrOfDOFs();

% create joint position iDynTree objects
% Note: 'JointPosDoubleArray' is a special type for future evolution which
% will handle quaternions. But for now the type has the format as 
% 'JointDOFsDoubleArray'.
qi_idyn   = iDynTree.JointPosDoubleArray(dofs); 
dqi_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
d2qi_idyn = iDynTree.JointDOFsDoubleArray(dofs);

% Base link index for later applying forward kynematics
base_link_index = estimator.model().getFrameIndex('base_link');

%% Specify unknown wrenches

% We need to set the location of the unknown wrench. We express the unknown
% wrench at the origin of the l_sole frame
unknownWrench = iDynTree.UnknownWrenchContact();
unknownWrench.unknownType = iDynTree.FULL_WRENCH;

% the position is the origin, so the conctact point wrt to base_link is zero
unknownWrench.contactPoint.zero();

% The fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class: we consider the pole reaction on the base link as the only 
% external force.
% Build an empty list.
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();
fullBodyUnknowns.addNewContactInFrame(estimator.model(),base_link_index,unknownWrench);

% Print the unknowns to make sure that everything is properly working
fullBodyUnknowns.toString(estimator.model())


%% The estimated sensor measurements
% `estimator.sensors()` gets used sensors (returns `SensorList`)
% ex: `estimator.sensors.getNrOfSensors(iDynTree.ACCELEROMETER)`
%     `estimator.sensors.getSensor(iDynTree.ACCELEROMETER,1)`
estMeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

% Memory allocation for output variables
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);
estContactForces = iDynTree.LinkContactWrenches(estimator.model());


%% Select sensors indices from iDynTree model, matching the list 'jointsToCalibrate'.
% Go through 'data.frames', 'data.parts' and 'data.labels' and build :
% - the joint vectors
% - the sensor list for the current part (part: right_leg, left_arm,...).
% This is a list of indexes, that will be later used for retrieving the
% sensor predicted measurements and the real measure from the captured data.
sensorsIdxListModel = [];
sensorsIdxListFile  = [];
jointsIdxListModel  = [];
jointsLabelIdx = 0;

for frame = 1:length(data.frames)
    if strcmp(data.parts(frame),jointsToCalibrate.parts(part))
        if strcmp(data.type(frame),'inertialMTB')
            if mtbSensorAct_left_leg{frame}
                sensorsIdxListModel = [sensorsIdxListModel ...
                    estimator.sensors.getSensorIndex(iDynTree.ACCELEROMETER,...
                    char(data.frames(frame)))];
                sensorsIdxListFile = [sensorsIdxListFile frame];
            end
        elseif strcmp(data.type{frame}, 'stateExt:o')
            jointsLabelIdx = frame;
        else
            error('costFunctionSigma: wrong type ',...
            'Error.\nWrong data type of sensor data. Valid types are "inertialMTB" and "stateExt:o" !!');
        end
    end
end

% Select from label index the joints associated to the current processed part.
qsRad    = ['qsRad_' data.labels{jointsLabelIdx}];
dqsRad   = ['dqsRad_' data.labels{jointsLabelIdx}];
d2qsRad  = ['d2qsRad_' data.labels{jointsLabelIdx}];

eval(['q0i = data.' qsRad '(:,subsetVec_idx);']);
eval(['dqi = data.' dqsRad '(:,subsetVec_idx);']);
eval(['d2qi = data.' d2qsRad '(:,subsetVec_idx);']);

% mapping of 'jointsToCalibrate.partJoints' into the iDynTree joint list.
for joint = 1:length(jointsToCalibrate.partJoints{part})
    % get joint index
    jointsIdxListModel = [jointsIdxListModel...
        estimator.model.getJointIndex(jointsToCalibrate.partJoints{part}{joint})];
end
%convert indices to matlab
jointsIdxListModel = jointsIdxListModel+1;

%% compute predicted measurements
% We compute here the final cost 'e'. As it is a sum of norms, we can also
% compute it as :   v^\top \dot v    , v being a vector concatenation of
% all the components of the sum. Refer to equation(1) in https://bitbucket.org/
% gnuno/jointoffsetcalibinertialdoc/src/6c2f99f3e1be59c8021e4fc5e522fa21bdd97037/
% Papers/PaperOnOffsetsCalibration.svg?at=fix/renderingMindmaps
%
% 'costVec' will be a cell array of cells 'costVec_ts'
costVec_ts = cell(length(sensorsIdxListModel),1);
costVec = cell(length(subsetVec_idx),1);

%DEBUG
sensMeasNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));
sensEstNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));
costNormMat = zeros(length(subsetVec_idx),length(sensorsIdxListModel));

sensMeasCell = cell(length(subsetVec_idx),length(sensorsIdxListModel));
sensEstCell = cell(length(subsetVec_idx),length(sensorsIdxListModel));

for ts = 1:length(subsetVec_idx)
    
    % Fill iDynTree joint vectors.
    % Warning!! iDynTree takes in input **radians** based units,
    % while the iCub port stream **degrees** based units.
    qisRobotDOF = zeros(dofs,1); qisRobotDOF(jointsIdxListModel,1) = q0i(:,ts) + Dq;
    dqisRobotDOF = zeros(dofs,1); dqisRobotDOF(jointsIdxListModel,1) = dqi(:,ts);
    d2qisRobotDOF = zeros(dofs,1); d2qisRobotDOF(jointsIdxListModel,1) = d2qi(:,ts);
    qi_idyn.fromMatlab(qisRobotDOF);
    dqi_idyn.fromMatlab(dqisRobotDOF);
    d2qi_idyn.fromMatlab(d2qisRobotDOF);
    
    % Update the kinematics information in the estimator
    estimator.updateKinematicsFromFixedBase(qi_idyn,dqi_idyn,d2qi_idyn,base_link_index,grav_idyn);
    
    % run the estimation
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estMeasurements,estContactForces,estJointTorques);
    
    % Get predicted and measured sensor data for each sensor referenced in
    % 'sensorsIdxList' and build a single 'diff' vector for the whole data set.
    for acc_i = 1:length(sensorsIdxListModel)
        % get predicted measurement on sensor frame
        estimatedSensorLinAcc = iDynTree.LinearMotionVector3();
        estMeasurements.getMeasurement(iDynTree.ACCELEROMETER,sensorsIdxListModel(acc_i),estimatedSensorLinAcc);
        sensEst = estimatedSensorLinAcc.toMatlab;
        % correction for MTB mounted upside-down
        if data.isInverted{acc_i}
            sensEst = real_R_model*sensEst;
        end
        
        % get measurement table ys_xxx_acc [3xnSamples] from captured data,
        % and then select the sample 's' (<=> timestamp).
        ys   = ['ys_' data.labels{sensorsIdxListFile(acc_i)}];
        eval(['sensMeas = data.' ys '(:,ts);']);
        
        % compute the cost for 1 sensor / 1 timestamp
        costVec_ts{acc_i} = (sensMeas - sensEst);
        %DEBUG
        sensMeasNormMat(ts,acc_i) = norm(sensMeas,2);
        sensEstNormMat(ts,acc_i) = norm(sensEst,2);
        costNormMat(ts,acc_i) = norm(costVec_ts{acc_i},2);
        sensMeasCell{ts,acc_i} = sensMeas';
        sensEstCell{ts,acc_i} = sensEst';
    end
    
    costVec{ts} = cell2mat(costVec_ts);
end


% Final cost = norm of 'costVec'
costVecMat = cell2mat(costVec);
optimFunctionProps = functions(optimFunction);
if strcmp(optimFunctionProps.function,'lsqnonlin')
    e = costVecMat;
else
    e = costVecMat'*costVecMat;
end


%% DEBUG: plot debug data
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
% %% DEBUG: Log data for later plotting gravity as 3D vector
% 
% % log data
% logFile = 'logSensorMeasVsEst.mat';
% save(logFile,'sensMeasCell','sensEstCell');
% 
% pause;

end

