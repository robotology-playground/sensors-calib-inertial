% Test repeatability of the accelerometers calibration procedure
% 
% This script runs the calibration script `sensorSelfCalibrator` for each training sequence acquired data selected in
% the list seqNum. The calibration is done on the sensors `accNames` and the resulting `calibrationMap` files copied to
% the destination folder `destFolder`. If one wish to acquire new data instead of processing old training data, set
% `-1` in `seqNum` for the respective desired iteration. For instance: seqNum=[25,26,27,-1];
% After this script is run, the drift of the parameters can be visualized by running the script
% `accelerometersCalibrationDrift.m`
% 
% ====== Tips: ======
% - for running the calibration on the same acquired data sequence, just repeat its number in seqNum:
% seqNum=[<n>,<n>,...,<n>].
% - for using the same offset estimated previously from training data sequence <n>, replace "calibArray(runIter).centre"
% by "calibArray(<n>).centre".
% - for other invariant parameters specific to the accelerometers calibration, set them in `sensorSelfCalibratorInit.m`
% - set the `destFolder`, `accNames` and `seqNum` init parameters in PARAMETERS section below
% - the training data is stored in the path defined by `dataPath` set in `sensorSelfCalibratorInit.m`.
% 

% PERFORMED TESTS
% 
% We've checked that, after running a first set of calibrations (saved into `calibrationDatabase-previous.mat`), if we
% run again the same set but using an imposed acc. offset to the quadfit algorithm, we obtain the same calibrated gains
% (saved into `calibrationDatabase-new.mat`).
% => shows that the calibration algorithm is stable if the same offset is used between two calibration iterations.

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

% Folder where `calibrationMap.mat` generated files will be copied
destFolder = '/Users/nunoguedelha/dev/green-icub-inertial-sensors-calibration-datasets/repeatability-test-10000samples-imposed-offset/14-12-2018_offsetFrom_14_12_2018';
% Accelerometers to be calibrated
accNames(1,1:8) = {...
    'l_upper_leg_mtb_acc_10b1'
    'l_upper_leg_mtb_acc_10b2'
    'l_upper_leg_mtb_acc_10b3'
    'l_upper_leg_mtb_acc_10b4'
    'l_lower_leg_mtb_acc_10b8'
    'l_lower_leg_mtb_acc_10b9'
    'l_lower_leg_mtb_acc_10b10'
    'l_lower_leg_mtb_acc_10b11'}';
% Data dump training sequences to be used in the calibration
seqNum = [297,298,299];

% calibration database
calibrationDatabaseName = 'calibrationDatabase-previous.mat';

%% ======= TEST ==============

% get the last saved calibrationMap iter number
maxFilenum = 0;
listOfCalibFiles = dir([destFolder '/calibrationMap*.mat']);
if ~isempty(listOfCalibFiles)
    for filename = {listOfCalibFiles.name}
        splitName = textscan(filename{1},'%s','delimiter','_');
        splitName = textscan(splitName{1}{end},'%s','delimiter','.');
        filenum = str2num(splitName{1}{1});
        if (filenum>maxFilenum)
            maxFilenum = filenum;
        end
    end
end

global repeatabilityTestSeqNum;
global predefinedOffsets; predefinedOffsets = containers.Map();
% load the calibration database holding the previously calibrated offsets
load(calibrationDatabaseName,'calibrationDatabase');

% for each iteration:
% - select the acquired data sequence number (this will overwrite the setting in the `sensorSelfCalibratorInit.m`,
% - gather the offsets from the calibration database for all the sensors, for the ongoing iteration,
% - run the calibration script `sensorSelfCalibrator` in the nested (safe) workspace of a local function,
% - copy the resulting `calibrationMap` into the destination folder.
for runIter = 1:numel(seqNum)
    repeatabilityTestSeqNum = seqNum(runIter);
%     for accName = accNames
%         % gather all the offsets (ellipsoid centre) previously identified
%         calibArray = calibrationDatabase(accName{1});
%         predefinedOffsets(accName{1}) = calibArray(runIter).centre; % replace `runIter` by <n> for using the same offset <n>
%     end
    runCalibInSafeWorkspace();
    system(['cp ./calibrationMap.mat ' destFolder '/calibrationMap_' num2str(maxFilenum+runIter) '.mat']);
end


%% ======= Static local functions ============

% allows to run the script `sensorSelfCalibrator` in a nested workspace to avoid variable collisions
function runCalibInSafeWorkspace()

run sensorSelfCalibrator;

end
