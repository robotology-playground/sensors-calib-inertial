% This script generates all required paths to be added to Matlab/Octave
% path in order to run the configuration scripts, package functions or
% class functions from any subfolder of the application.

% change to main source folder (parent folder of main script calling this one)
currentPath=pwd;
cd ..

% add critical folders to the path
srcFolder=pwd;
confFolder=fullfile(pwd,filesep,'conf');
appFolder=fullfile(pwd,filesep,'app');
utilsFolder=fullfile(pwd,filesep,'utils');

% add folders and subfolders (except for srcFolder)
addpath(...
    srcFolder,...
    genpath(confFolder),...
    genpath(appFolder),...
    genpath(utilsFolder),...
    '-begin');

% back to initial folder
cd(currentPath);
