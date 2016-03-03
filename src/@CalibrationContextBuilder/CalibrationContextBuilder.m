classdef CalibrationContextBuilder < handle
    % This class holds the context for the cost function to be minimised,
    % as the init methods and the a specific cost function.
    % 
    % Detailed explanation goes here
        
    properties (SetAccess = public, GetAccess = public)
        grav_idyn             %% gravity iDynTree object
        dofs                  %% joint information: DOF
        mtbSensorAct          %% activation of sensors
        qi_idyn               %% joint position iDynTree object
        dqi_idyn              %% joint velocity iDynTree object
        d2qi_idyn             %% joint acceleration iDynTree object
        estimator             %% estimator for computing the estimated sensor measurements
        base_link_index       %% input param of estimator. iDynTree model indexing
        fullBodyUnknowns      %% input param of estimator
        estMeasurements       %% input param of estimator
        sink1                 %% sink for output estContactForces
        sink2                 %% sink for output estJointTorques
        sensorsIdxListModel = []; %% subset of active sensors: indices from iDynTree model
        sensorsIdxListFile  = []; %% subset of active sensors: indices from 'data.frame' list,
                                  %  ordered as per the data.log format.
        jointsLabelIdx = 0;       %% index of 'StateExt' in 'data.frame' list
        jointsIdxListModel  = []; %% map 'joint to calibrate' to iDynTree joint index
        estimatedSensorLinAcc     %% predicted measurement on sensor frame
        q0i                       %% joint positions for the current processed part.
        dqi                       %% joint velocities for the current processed part.
        d2qi                      %% joint accelerations for the current processed part.
        DqiEnc                    %% vrtual joint offsets from the encoders.
        %% specific to APPROACH 2: measurements projected on each link
        traversal_Lk              %% full traversal for computing the link positions
        fixedBasePos              %% full tree joint positions (including base link)
                                   % (required by the estimator interface,
                                   % but the base position is not really
                                   % relevant for computing the transforms
                                   % between segment frames).
        linkPos                   %% link positions w.r.t. the chosen base (base="projection link")
        segments                  %% list of segments for current part.
    end
    
    methods
        function obj = CalibrationContextBuilder()
            %% Prepare inputs for updating the kinematics information in the estimator
            %
            % Compute the kinematics information necessary for the accelerometer
            % sensor measurements estimation. We assume the robot root link is fixed to
            % the ground (steady kart pole). We then assume to know the gravity (ground
            % truth) projected on the frame (base_link) fixed to the root link. For more
            % info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions.
            %
            obj.grav_idyn = iDynTree.Vector3();
            grav = [0.0;0.0;-9.81];
            obj.grav_idyn.fromMatlab(grav);
            
            %% Create the estimator and model...
            %
            % Create an estimator class, load the respective model from URDF file and
            % set the robot state constant parameters
            
            % Create estimator class
            obj.estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
            
            % Load model and sensors from the URDF file
            obj.estimator.loadModelAndSensorsFromFile('../models/iCubGenova02/iCubFull.urdf');
            
            % Check if the model was correctly created by printing the model
            obj.estimator.model.toString()
            
            % Base link index for later applying forward kynematics
            % (specific to APPROACH 1)
            obj.base_link_index = obj.estimator.model.getFrameIndex('base_link');
            
            % Get joint information: DOF
            obj.dofs = obj.estimator.model.getNrOfDOFs();
            
            % create joint position iDynTree objects
            % Note: 'JointPosDoubleArray' is a special type for future evolution which
            % will handle quaternions. But for now the type has the format as
            % 'JointDOFsDoubleArray'.
            obj.qi_idyn   = iDynTree.JointPosDoubleArray(obj.dofs);
            obj.dqi_idyn  = iDynTree.JointDOFsDoubleArray(obj.dofs);
            obj.d2qi_idyn = iDynTree.JointDOFsDoubleArray(obj.dofs);
            
            % Set the position of base link
            obj.fixedBasePos = iDynTree.FreeFloatingPos(obj.estimator.model);
%            obj.fixedBasePos.worldBasePos = iDynTree.Transform.Identity();

            %% Specify unknown wrenches (specific to APPROACH 1)
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
            obj.fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(obj.estimator.model());
            obj.fullBodyUnknowns.clear();
            obj.fullBodyUnknowns.addNewContactInFrame(obj.estimator.model, ...
                                                      obj.base_link_index, ...
                                                      unknownWrench);
            
            % Print the unknowns to make sure that everything is properly working
            obj.fullBodyUnknowns.toString(obj.estimator.model())
            
            
            %% The estimated sensor measurements
            % `estimator.sensors()` gets used sensors (returns `SensorList`)
            % ex: `estimator.sensors.getNrOfSensors(iDynTree.ACCELEROMETER)`
            %     `estimator.sensors.getSensor(iDynTree.ACCELEROMETER,1)`
            obj.estMeasurements = iDynTree.SensorsMeasurements(obj.estimator.sensors);
            
            % Memory allocation for unused output variables
            obj.sink1 = iDynTree.LinkContactWrenches(obj.estimator.model);
            obj.sink2 = iDynTree.JointDOFsDoubleArray(obj.dofs);
            
            % estimation outputs
            obj.estimatedSensorLinAcc = iDynTree.LinearMotionVector3();
            
            % full traversal for computing the base to link k transforms
            obj.traversal_Lk = iDynTree.Traversal();
            obj.linkPos = iDynTree.LinkPositions();
            
        end
        
        function buildSensorsNjointsIDynTreeListsForActivePart(obj,data,part,jointsToCalibrate,mtbSensorAct)
            % get list of activated sensors
            obj.mtbSensorAct = mtbSensorAct;
            
            % load joint virtual encoder offsets
            obj.DqiEnc = jointsToCalibrate.partJointsInitOffsets{part}';
            
            % load segments list for current part (ex: segments of left leg part
            % are: 'l_upper_leg', 'l_lower_leg', 'l_foot'.
            obj.segments = jointsToCalibrate.partSegments{part};
            
            %% Select sensors indices from iDynTree model, matching the list 'jointsToCalibrate'.
            % Go through 'data.frames', 'data.parts' and 'data.labels' and build :
            % - the joint list to calibrate mapped into the iDynTree indices
            % - the sensor list for the current part (part: right_leg, left_arm,...).
            % This is a list of indexes, that will be later used for retrieving the
            % sensor predicted measurements and the real measure from the captured data.
            for frame = 1:length(data.frames)
                if strcmp(data.parts(frame),jointsToCalibrate.parts(part))
                    if strcmp(data.type(frame),'inertialMTB')
                        if obj.mtbSensorAct{frame}
                            obj.sensorsIdxListModel = [obj.sensorsIdxListModel ...
                                obj.estimator.sensors.getSensorIndex(iDynTree.ACCELEROMETER,...
                                char(data.frames(frame)))];
                            obj.sensorsIdxListFile = [obj.sensorsIdxListFile frame];
                        end
                    elseif strcmp(data.type{frame}, 'stateExt:o')
                        obj.jointsLabelIdx = frame;
                    else
                        error('costFunctionSigma: wrong type ',...
                            'Error.\nWrong data type of sensor data. Valid types are "inertialMTB" and "stateExt:o" !!');
                    end
                end
            end
            
            % mapping of 'jointsToCalibrate.partJoints' into the iDynTree joint list.
            for joint = 1:length(jointsToCalibrate.partJoints{part})
                % get joint index
                obj.jointsIdxListModel = [obj.jointsIdxListModel...
                    obj.estimator.model.getJointIndex(jointsToCalibrate.partJoints{part}{joint})];
            end
            %convert indices to matlab
            obj.jointsIdxListModel = obj.jointsIdxListModel+1;
        end
        
        function loadJointNsensorsDataSubset(obj,data,subsetVec_idx)
            % Select from label index the joints associated to the current processed part.
            qsRad    = ['qsRad_' data.labels{obj.jointsLabelIdx}];
            dqsRad   = ['dqsRad_' data.labels{obj.jointsLabelIdx}];
            d2qsRad  = ['d2qsRad_' data.labels{obj.jointsLabelIdx}];
            
            eval(['obj.q0i = data.' qsRad '(:,subsetVec_idx);']);
            eval(['obj.dqi = data.' dqsRad '(:,subsetVec_idx);']);
            eval(['obj.d2qi = data.' d2qsRad '(:,subsetVec_idx);']);
        end
        
        function e = costFunctionSigma(obj,Dq, data, subsetVec_idx, optimFunction)
            %COSTFUNCTIONSIGMA Summary of this function goes here
            %   Detailed explanation goes here
            %
            %% compute predicted measurements
            % We compute here the final cost 'e'. As it is a sum of norms, we can also
            % compute it as :   v^\top \dot v    , v being a vector concatenation of
            % all the components of the sum. Refer to equation(1) in https://bitbucket.org/
            % gnuno/jointoffsetcalibinertialdoc/src/6c2f99f3e1be59c8021e4fc5e522fa21bdd97037/
            % Papers/PaperOnOffsetsCalibration.svg?at=fix/renderingMindmaps
            %
            % 'costVec' will be a cell array of cells 'costVec_ts'
            costVec_ts = cell(length(obj.sensorsIdxListModel),1);
            costVec = cell(length(subsetVec_idx),1);
            
            %DEBUG
            sensMeasNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            sensEstNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            costNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            
            sensMeasCell = cell(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            sensEstCell = cell(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            
            for ts = 1:length(subsetVec_idx)
                
                % Fill iDynTree joint vectors.
                % Warning!! iDynTree takes in input **radians** based units,
                % while the iCub port stream **degrees** based units.
                % Also add joint offsets from a previous result.
                qisRobotDOF = zeros(obj.dofs,1); qisRobotDOF(obj.jointsIdxListModel,1) = obj.q0i(:,ts) + obj.DqiEnc + Dq;
                dqisRobotDOF = zeros(obj.dofs,1); dqisRobotDOF(obj.jointsIdxListModel,1) = obj.dqi(:,ts);
                d2qisRobotDOF = zeros(obj.dofs,1); d2qisRobotDOF(obj.jointsIdxListModel,1) = obj.d2qi(:,ts);
                obj.qi_idyn.fromMatlab(qisRobotDOF);
                obj.dqi_idyn.fromMatlab(dqisRobotDOF);
                obj.d2qi_idyn.fromMatlab(d2qisRobotDOF);
                
                % Update the kinematics information in the estimator
                obj.estimator.updateKinematicsFromFixedBase(obj.qi_idyn,obj.dqi_idyn,obj.d2qi_idyn, ...
                                                            obj.base_link_index,obj.grav_idyn);
                
                % run the estimation
                obj.estimator.computeExpectedFTSensorsMeasurements(obj.fullBodyUnknowns,obj.estMeasurements,obj.sink1,obj.sink2);
                
                % Get predicted and measured sensor data for each sensor referenced in
                % 'sensorsIdxList' and build a single 'diff' vector for the whole data set.
                for acc_i = 1:length(obj.sensorsIdxListModel)
                    % get predicted measurement on sensor frame
                    obj.estMeasurements.getMeasurement(iDynTree.ACCELEROMETER,obj.sensorsIdxListModel(acc_i),obj.estimatedSensorLinAcc);
                    sensEst = obj.estimatedSensorLinAcc.toMatlab;
                    % correction for MTB mounted upside-down
                    if FrameConditioner.mtbInvertedFrames{acc_i}
                        sensEst = FrameConditioner.real_R_model*sensEst;
                    end
                    
                    % get measurement table ys_xxx_acc [3xnSamples] from captured data,
                    % and then select the sample 's' (<=> timestamp).
                    ys   = ['ys_' data.labels{obj.sensorsIdxListFile(acc_i)}];
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
            
        end
        
        function e = costFunctionSigmaProjOnEachLink(obj,Dq,data,subsetVec_idx,optimFunction)
            % We defined in 'jointsNsensorsDefinitions' a segment i as a link for which
            % parent joint i and joint i+1 axis are not concurrent. For instance 'root_link',
            % 'r_upper_leg', 'r_lower_leg', 'r_foot' are segments of the right leg. 'r_hip_1',
            % 'r_hip2' and r_hip_3' are part of the 3 DoF hip joint.
            % This function computes a sub-cost function e_k for each segment k. Each
            % cost e_k is the sum of variances of all the sensor measurements projected
            % on the link k frame F_k.
            %
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
            costVec_Lk_ts = cell(length(obj.sensorsIdxListModel),1);
            costVec_Lk = cell(length(subsetVec_idx),1);
            costVec = cell(length(obj.segments),1);
            
            %DEBUG
            % sensMeasNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            % sensEstNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            % costNormMat = zeros(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            % 
            % sensMeasCell = cell(length(subsetVec_idx),length(obj.sensorsIdxListModel));
            % sensEstCell = cell(length(subsetVec_idx),length(obj.sensorsIdxListModel));

            %% Sum the costs projected on every link (we later might exclude the base
            % link which doesn't have accelerometers and assume a theoretical g_0.
            %
            % Definition:
            %
            % $$e_T = \sum_{k=0}^{N} e_k$$
            %
            for segmentk = 1:length(obj.segments)
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
                Lk_sensMeasCell = cell(length(subsetVec_idx),length(obj.sensorsIdxListModel));
                mu_k = cell(length(subsetVec_idx),1);
                
                % set 'Lk' as the traversal base to be used at current
                % iteration
                Lk = obj.estimator.model.getLinkIndex(obj.segments{segmentk});
                obj.estimator.model.computeFullTreeTraversal(obj.traversal_Lk, Lk);
                
                
                for ts = 1:length(subsetVec_idx)
                    
                    % Complete the full floating base position configuration
                    % by filling the joint positions.
                    % Warning!! iDynTree takes in input **radians** based units,
                    % while the iCub port stream **degrees** based units.
                    % Also add joint offsets from a previous result.
                    qisRobotDOF = zeros(obj.dofs,1); qisRobotDOF(obj.jointsIdxListModel,1) = obj.q0i(:,ts) + obj.DqiEnc + Dq;
                    % obj.qi_idyn.fromMatlab(qisRobotDOF);
                    for joint_i = 0:(obj.dofs-1)
                        obj.fixedBasePos.jointPos.setVal(joint_i,qisRobotDOF(joint_i+1));
                    end
                    
                    % Project on link frame Lk all measurements from each sensor referenced in
                    % 'sensorsIdxList'and compute the mean.
                    for acci = 1:length(obj.sensorsIdxListModel)
                        % get sensor handle
                        sensor = obj.estimator.sensors.getSensor(iDynTree.ACCELEROMETER,obj.sensorsIdxListModel(acci));
                        accSensor = iDynTree.AccelerometerSensor(sensor);
                        % get the sensor to link i transform Li_H_acci
                        Li_H_acci = accSensor.getLinkSensorTransform();
                        % get the projection link k to link i transform Lk_H_Li
                        iDynTree.ForwardPositionKinematics(obj.estimator.model, obj.traversal_Lk, ...
                            obj.fixedBasePos, obj.linkPos);
                        Li = accSensor.getParentLinkIndex();
                        Lk_H_Li = obj.linkPos(Li);
                        % get measurement table ys_xxx_acc [3xnSamples] from captured data,
                        % and then select the sample 's' (<=> timestamp).
                        ys   = ['ys_' data.labels{obj.sensorsIdxListFile(acci)}];
                        eval(['sensMeas = data.' ys '(:,ts);']);
                        % project the measurement in link Lk frame and store it for
                        % later computing the variances
                        Lk_sensMeasCell{ts,acci} = Lk_H_Li * Li_H_acci * sensMeas;
                    end
                    % compute the mean
                    mu_k{ts} = mean(cell2mat(Lk_sensMeasCell{ts,:}),2);
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
                % Compute the variances for each ts and acc_i. Formulate computation
                % as variance = diff' * diff.
                for ts = 1:length(subsetVec_idx)
                    for acci = 1:length(obj.sensorsIdxListModel)
                        % compute the cost for 1 sensor / 1 timestamp, using previously
                        % computed measurement (ts,acci) and mean(ts), and previously
                        % computed mean, all projected on frame link k.
                        costVec_Lk_ts{acci} = (Lk_sensMeasCell{ts,acci} - mu_k{ts});
                        %DEBUG
                        %             sensMeasNormMat(ts,acci) = norm(sensMeas,2);
                        %             sensEstNormMat(ts,acci) = norm(sensEst,2);
                        %             costNormMat(ts,acci) = norm(costVec_Lk_ts{acci},2);
                        %             sensMeasCell{ts,acci} = sensMeas';
                        %             sensEstCell{ts,acci} = sensEst';
                    end
                    
                    costVec_Lk{ts} = cell2mat(costVec_Lk_ts);
                end
                costVec{Lk} = cell2mat(costVec_Lk);
            end
            
            % Final cost = norm of 'costVec'
            costVecMat = cell2mat(costVec);
            optimFunctionProps = functions(optimFunction);
            if strcmp(optimFunctionProps.function,'lsqnonlin')
                e = costVecMat;
            else
                e = costVecMat'*costVecMat;
            end
          
            
            
            
            % % %                         % correction for MTB mounted upside-down
            % % %                         if FrameConditioner.mtbInvertedFrames{acc_i}
            % % %                             sensEst = FrameConditioner.real_R_model*sensEst;
            % % %                         end
            % % %
            % % %                     end
            % % %
            % % %                     costVec{ts} = cell2mat(costVec_ts);
            % % %                 end
            % % %
            % % %
            % % %                 % Final cost = norm of 'costVec'
            % % %                 costVecMat = cell2mat(costVec);
            % % %                 optimFunctionProps = functions(optimFunction);
            % % %                 if strcmp(optimFunctionProps.function,'lsqnonlin')
            % % %                     e = costVecMat;
            % % %                 else
            % % %                     e = costVecMat'*costVecMat;
            % % %                 end
            
        end
        
    end
    
    
    % % DEBUG: plot debug data
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

