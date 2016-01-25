dynComp = iDynTree.DynamicsComputations();
dynComp.loadRobotModelFromFile('iCubRightLegV25.urdf');

zeroVec = iDynTree.VectorDynSize(6);
zeroGrav = iDynTree.SpatialAcc();

% set zero state
dynComp.setRobotState(zeroVec,zeroVec,zeroVec,zeroGrav);

% setup fwd kinematics for drake model 
nBody = iCub_dmodel.NB;

zeroDrake   = zeros(nBody,1);

aaXup = cell(nBody,1);
aaXa = cell(nBody,1);

%% Compute transforms with respect to the parent for all links
% aaXup{i} contains {}^{i}X_{\lambda(i)}
for i = 1 : nBody
   [ XJ, ~ ] = jcalc( iCub_dmodel.jtype{i}, zeroDrake(i) );
   aaXup{i} = XJ * iCub_dmodel.Xtree{i};
end

%% Compute transforms with respect to the base for all links
% aaXa{i} contains {}^{i}X_{0}
for i = 1:length(iCub_dmodel.parent)
   if iCub_dmodel.parent(i) == 0
      aaXa{i} = aaXup{i};
   else
      aaXa{i} = aaXup{i} * aaXa{iCub_dmodel.parent(i)};
   end
end

% correction for MTB mounted upside-down 
right_R_wrong = [-1, 0, 0, 0, 0, 0;  ...
                  0,-1, 0, 0, 0, 0; ...
                  0, 0, 1, 0, 0, 0; ... 
                  0, 0, 0,-1, 0, 0; ...
                  0, 0, 0, 0,-1, 0; ...
                  0, 0, 0, 0, 0, 1];

% r_upper_leg : link 3
drake_r_upper_leg_X_urdf_r_upper_leg = aaXa{3}*linAng2AngLin(dynComp.getRelativeTransform('root_link','r_upper_leg').asAdjointTransform.toMatlab);
drake_r_upper_leg_X_urdf_r_hip_3 = aaXa{3}*linAng2AngLin(dynComp.getRelativeTransform('root_link','r_hip_3').asAdjointTransform.toMatlab);

for i = 1:length(mtbSensorCodes)
    if( strcmp(mtbSensorLink{i},'r_upper_leg') )
        eval(strcat('drake_r_upper_leg_X_urdf_',mtbSensorFrames{i},' = aaXa{3}*linAng2AngLin(dynComp.getRelativeTransform(''root_link'',''', mtbSensorFrames{i} ,''').asAdjointTransform.toMatlab);'));
        if( mtbInvertedFrames{i} )
            eval(strcat('drake_r_upper_leg_X_urdf_',mtbSensorFrames{i},' = ', 'drake_r_upper_leg_X_urdf_',mtbSensorFrames{i},'*right_R_wrong;'));
        end
    end
end

% r_lower_leg : link 4
drake_r_lower_leg_X_urdf_r_lower_leg = aaXa{4}*linAng2AngLin(dynComp.getRelativeTransform('root_link','r_lower_leg').asAdjointTransform.toMatlab);
for i = 1:length(mtbSensorCodes)
    if( strcmp(mtbSensorLink{i},'r_lower_leg') )
        eval(strcat('drake_r_lower_leg_X_urdf_',mtbSensorFrames{i},' = aaXa{4}*linAng2AngLin(dynComp.getRelativeTransform(''root_link'',''', mtbSensorFrames{i} ,''').asAdjointTransform.toMatlab);'));
        if( mtbInvertedFrames{i} )
            eval(strcat('drake_r_lower_leg_X_urdf_',mtbSensorFrames{i},' = ', 'drake_r_lower_leg_X_urdf_',mtbSensorFrames{i},'*right_R_wrong;'));
        end
    end
end

% r_foot : link 6 
drake_r_foot_X_urdf_r_foot = aaXa{6}*linAng2AngLin(dynComp.getRelativeTransform('root_link','r_foot').asAdjointTransform.toMatlab);
for i = 1:length(mtbSensorCodes)
    if( strcmp(mtbSensorLink{i},'r_foot') )
        eval(strcat('drake_r_foot_X_urdf_',mtbSensorFrames{i},' = aaXa{6}*linAng2AngLin(dynComp.getRelativeTransform(''root_link'',''', mtbSensorFrames{i} ,''').asAdjointTransform.toMatlab);'));
        if( mtbInvertedFrames{i} )
            eval(strcat('drake_r_foot_X_urdf_',mtbSensorFrames{i},' = ', 'drake_r_foot_X_urdf_',mtbSensorFrames{i},'*right_R_wrong;'));
        end
    end
end

drake_root_link_X_X_urdf_r_foot = aaXa{6};

Simulink.saveVars('iCubSensTransforms.m', '-regexp', 'drake_*')