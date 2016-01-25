clear all
close all
clc

% to run this script make sure to have drake in your path


%NB = 2;

R = RigidBodyManipulator('iCubRightLegV25.urdf');
iCub_dmodel = R.featherstone;

NB = iCub_dmodel.NB;
for i = 1 : NB
   iCub_dmodel.jtype{i}      = 'R';
   iCub_dmodel.appearance{i} = '1';
   iCub_dmodel.linkname{i}   = R.body(i+1).linkname;
   iCub_dmodel.jointname{i}  = R.body(i+1).jointname;
end

% substitute some horrible composite name (just for the right leg)
if( strcmp(iCub_dmodel.linkname{2},'r_hip_2+r_hip_3') )
    iCub_dmodel.linkname{2} = 'r_hip_2';
end
if( strcmp(iCub_dmodel.linkname{3},'r_upper_leg+r_upper_leg_acc_mtb_11B5+r_upper_leg_acc_mtb_11B3+r_upper_leg_acc_mtb_11B2+r_upper_leg_acc_mtb_11B1+r_upper_leg_acc_mtb_11B6+r_upper_leg_acc_mtb_11B7+r_upper_leg_acc_mtb_11B4') )
    iCub_dmodel.linkname{3} = 'r_upper_leg';
end
if( strcmp(iCub_dmodel.linkname{4},'r_lower_leg+r_lower_leg_acc_mtb_11B11+r_lower_leg_acc_mtb_11B10+r_lower_leg_acc_mtb_11B8+r_lower_leg_acc_mtb_11B9') )
    iCub_dmodel.linkname{4} = 'r_lower_leg';
end
if( strcmp(iCub_dmodel.linkname{6},'r_ankle_2+r_foot+r_sole+r_foot_acc_mtb_11B13+r_foot_acc_mtb_11B12') )
    iCub_dmodel.linkname{6} = 'r_foot';
end

% Save model to file 
Simulink.saveVars('iCub.m','iCub_dmodel');

