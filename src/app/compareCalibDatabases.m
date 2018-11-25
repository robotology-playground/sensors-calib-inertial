% This script compares 2 calibrationDatabase files
% 

% Add main folders in Matlab path
run generatePaths.m;

% clear all variables and close all previous figures
clear all
close all
clc
clear classes; %Clear static data
System.clearTimers(); % Clear all timers
import System.Const; % Define constants

%% ======= PARAMETERS ========
% Define folder where to read new calibration elements
accNames(1,1:11) = {...
    'l_upper_leg_mtb_acc_10b1'
    'l_upper_leg_mtb_acc_10b2'
    'l_upper_leg_mtb_acc_10b3'
    'l_upper_leg_mtb_acc_10b4'
    'l_upper_leg_mtb_acc_10b5'
    'l_upper_leg_mtb_acc_10b6'
    'l_upper_leg_mtb_acc_10b7'
    'l_lower_leg_mtb_acc_10b8'
    'l_lower_leg_mtb_acc_10b9'
    'l_lower_leg_mtb_acc_10b10'
    'l_lower_leg_mtb_acc_10b11'}';

%% ======= TEST ==============
% Load current database
load('calibrationDatabase-previous.mat','calibrationDatabase');
calibrationDatabase_previous = calibrationDatabase;
load('calibrationDatabase-new.mat','calibrationDatabase');
calibrationDatabase_new = calibrationDatabase;

% Compare the databases
for accName = accNames
    accCalibRecord_previous = calibrationDatabase_previous(accName{1});
    accCalibRecord_new = calibrationDatabase_new(accName{1});
    iterations = (1:numel(accCalibRecord_previous))';
    centreMat = [accCalibRecord_previous.centre]'-[accCalibRecord_new.centre]';
    Cmat =[accCalibRecord_previous.C]'-[accCalibRecord_new.C]';
    accShortName = System.toLatexInterpreterCompliant(getShortSensorName(accName{1}));
    % Offsets comparison
    figH = Plotter.plotNFuncTimeseries(...
        [],['Drift of ' accShortName ' offsets'],...
        ['drift_' accShortName '_offsets'],'m \cdot s^{-2}',...
        iterations,centreMat,{[accShortName ' offset$_x$'],[accShortName ' offset $_y$'],[accShortName ' offset $_z$']},...
        {'r-','g-','b-'},4,[],[],[]);
    % Calibration matrix comparison
    figH = Plotter.plotNFuncTimeseries(...
        [],['Drift of ' accShortName ' calibration matrix C'],...
        ['drift_' accShortName '_Cmatrix'],'ratio',...
        iterations,Cmat(:,[1 5 9 2 3 6]),{...
        [accShortName ' gain $xx$'],[accShortName ' gain $yy$'],[accShortName ' gain $zz$'],...
        [accShortName ' cross gain $yx$'],[accShortName ' cross gain $zx$'],...
        [accShortName ' cross gain $zy$']},...
        {'r-','g-','b-','c-','m-','y-'},4,[],[],[]);
end

%% ======= Static local functions ============

function shortName = getShortSensorName(fullSensorName)

splitName = textscan(fullSensorName,'%s','delimiter','_');
shortName = [splitName{1}{end-1} '_' splitName{1}{end}];

end
