function e = costFunctionSigma(data, vec_idx, estimator)
%COSTFUNCTIONSIGMA Summary of this function goes here
%   Detailed explanation goes here

    %% compute predicted measurements
    % Build the joint vectors
    q0i = data.q(:,subsetVec_idx)';
    dqi = data.dq(:,subsetVec_idx)';
    d2qi = data.d2q(:,subsetVec_idx)';
    % Fill iDynTree joint vectors
    q0i_idyn.fromMatlab(q0i);
    dqi_idyn.fromMatlab(dqi);
    d2qi_idyn.fromMatlab(d2qi);

    % Update the kinematics information in the estimator
    estimator.updateKinematicsFromFixedBase(q0i_idyn,dqi_idyn,ddqi_idyn,base_link_index,grav_idyn);



end

