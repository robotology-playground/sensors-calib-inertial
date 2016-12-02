%%         Calibration Validation on several datasets
%
%
%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

run calibValidationInit;

%% set init parameters 'ModelParams'
%
run jointsNsensorsSelectionsForValidation;
ModelParams = jointsNsensorsDefinitions(parts,jointsIdxes,jointsDq0,mtbSensorAct);

%% Update iterator and prepare log folders/files
%
if logTest
    if exist('./data/test/iterator.mat','file') == 2
        load('./data/test/iterator.mat','iterator');
        iterator = iterator+1;
    end
    save('./data/test/iterator.mat','iterator');
    
    figsFolder = ['./data/test/log_' num2str(iterator)];
    dataFolder = ['./data/test'];
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' figsFolder],'-echo')
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' dataFolder],'-echo')
    fileID = fopen([dataFolder '/log_' num2str(iterator) '.txt'],'w');
    fprintf(fileID,'modelPath = %s\n',modelPath);
    fprintf(fileID,'dataPath = %s\n',dataPath);
    fprintf(fileID,'dataSetNb = %s\n',dataSetNb);
    fprintf(fileID,'calibrationMapFile = %s\n',calibrationMapFile);
    fprintf(fileID,'iterator = %d\n',iterator);
    fclose(fileID);
end

%% ===================================== CALIBRATION VALIDATION ==============================
%

%% build input data before calibration
%

% Build input data without calibration applied
[data.bc,sensorsIdxListFile,sensMeasCell.bc] = buildInputDataSet(...
    loadSource,saveToCache,loadJointPos,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams);

% Common result buckets
pVecList = cell(1,length(sensorsIdxListFile));
dVecList = cell(1,length(sensorsIdxListFile));
dOrientList = cell(1,length(sensorsIdxListFile));
dOrientListBC = cell(1,length(sensorsIdxListFile));
dOrientListAC = cell(1,length(sensorsIdxListFile));
dList = cell(1,length(sensorsIdxListFile));

%% Apply calibration and reload input data
%

% Load existing calibration
if exist(calibrationMapFile,'file') == 2
    load(calibrationMapFile,'calibrationMap');
end

if ~exist('calibrationMap','var')
    error('calibrationMap not found');
end

% Build input data with calibration applied
[data.ac,sensorsIdxListFile,sensMeasCell.ac] = buildInputDataSet(...
    loadSource,saveToCache,false,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams,calibrationMap);


%% Check distance to 9.807 sphere manifold
%

% iteration list
activeAccs = ModelParams.mtbSensorCodes_list{1}(cell2mat(ModelParams.mtbSensorAct_list));
accIter = sensorsIdxListFile;

for acc_i = accIter
    %% distance to a centered sphere (R=9.807) before calibration
    [pVec.bc,dVec.bc,dOrient.bc,d.bc] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.bc{1,acc_i}(:,1),...
        sensMeasCell.bc{1,acc_i}(:,2),...
        sensMeasCell.bc{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    %% distance to a centered sphere (R=9.807) after calibration
    [pVec.ac,dVec.ac,dOrient.ac,d.ac] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.ac{1,acc_i}(:,1),...
        sensMeasCell.ac{1,acc_i}(:,2),...
        sensMeasCell.ac{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    pVecList{1,acc_i} = pVec;
    dVecList{1,acc_i} = dVec;
    dOrientList{1,acc_i} = dOrient;
    dList{1,acc_i} = d;
    
end

%% Plot figures
%

time = data.ac.tInit + data.ac.parsedParams.time(:);

for acc_i = accIter
    %% Plot distributions
    % Check if we should print to a log file
    if logTest
        FID = fopen([figsFolder '/distrib_' activeAccs{acc_i} '.txt'],'w');
    else
        FID = 1;
    end
    
    figure('Name',['calibration of MTB sensor ' activeAccs{acc_i}]);
    %set(gcf,'PositionMode','manual','Units','centimeters','Position',[5 5 50 200]);
    set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);

    % distr of signed distances before calibration
    subplot(1,3,1);
    title('distribution of distances to a centered \newline sphere (R=9.807)',...
        'Fontsize',16,'FontWeight','bold');
    prevh=plotNprintDistrb(FID,dOrientList{1,acc_i}.bc,false,'auto',1);
    plotNprintDistrb(FID,dOrientList{1,acc_i}.ac,true,[7/255 100/255 26/255],0.6,prevh);

    % close file
    if FID ~= 1
        fclose(FID);
    end
    
    %% Plot norm uniformity improvement
    subplot(1,3,2);
    title('Norm of sensor measurements','Fontsize',16,'FontWeight','bold');
    for iter = 1:subSamplingSize
        normMeas(iter) = norm(sensMeasCell.bc{1,acc_i}(iter,:));
    end
    hold on;
    grid ON;
    normbc = plot(time,normMeas,':b','lineWidth',2.0);
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    hold off;
    
    for iter = 1:subSamplingSize
        normMeas(iter) = norm(sensMeasCell.ac{1,acc_i}(iter,:));
    end
    hold on;
    grid ON;
    normac = plot(time,normMeas,'r','lineWidth',2.0);
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    hold off;
    set(gca,'FontSize',12);
    
    legend([normbc,normac],'Before calibration','After calibration')
    %% plot fitting
    subplot(1,3,3);
    title('Projection on ground truth \newline sphere manifold after calibration','Fontsize',16,'FontWeight','bold');
    plotFittingEllipse([0 0 0]',[9.807 9.807 9.807]',eye(3,3),sensMeasCell.ac{1,acc_i});

    if logTest
        set(gcf,'PaperPositionMode','auto');
        print('-dpng','-r300','-opengl',[figsFolder '/figs_' activeAccs{acc_i}]);
    end    
end

%% Plot joint trajectories
if loadJointPos
    figure('Name','chain joint positions q');
    set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
    title('chain joint positions q','Fontsize',16,'FontWeight','bold');
    hold on
    myColors = {'b','g','r','c','m','y'};
    colorIdx = 1;
    eval(['qsRad = data.bc.parsedParams.qsRad_' ModelParams.parts{1} '_state;']); qsRad = qsRad';
    for qIdx = 1:size(qsRad,2)
        plot(time,qsRad(:,qIdx)*180/pi,myColors{colorIdx},'lineWidth',2.0);
        colorIdx = colorIdx+1;
    end
    hold off
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Joints positions (degrees)','Fontsize',12);
    legend('Location','BestOutside',ModelParams.jointsToCalibrate.partJoints{1});
    set(gca,'FontSize',12);
    
    if logTest
        set(gcf,'PaperPositionMode','auto');
        print('-dpng','-r300','-opengl',[figsFolder '/jointTraject']);
    end
end

%% Plot bar graph of all accelerometers distributions before and after calibration

% build matrix of distances
for acc_i = accIter 
    dOrientListBC{1,acc_i} = dOrientList{1,acc_i}.bc;
    dOrientListAC{1,acc_i} = dOrientList{1,acc_i}.ac;
end

dOrientListBC=dOrientListBC(1,accIter);
dOrientListAC=dOrientListAC(1,accIter);
dOrientListBCmat = cell2mat(dOrientListBC);
dOrientListACmat = cell2mat(dOrientListAC);

%% Plot
figure;

bar([mean(dOrientListBCmat,1)' mean(dOrientListACmat,1)']);

xlabel('MTB board index','Fontsize',20);
ylabel('distance (m/s^2)','Fontsize',20);
grid on;

hold on;
errorbar([1:length(accIter)]-0.15,mean(dOrientListBCmat,1)',...
    std(dOrientListBCmat,0,1)',...
    'r*','lineWidth',2.5);
errorbar([1:length(accIter)]+0.15,mean(dOrientListACmat,1)',...
    std(dOrientListACmat,0,1)',...
    'b*','lineWidth',2.5);
hold off

legend('mean before calibration','mean after calibration',...
    '\sigma before calibration','\sigma after calibration');

if logTest
    set(gcf,'PaperPositionMode','auto');
    print('-dpng','-r300','-opengl',[figsFolder '/AllDistribBefNaft']);
end


%% Log all data
if logTest
    save([dataFolder '/log_' num2str(iterator) '_All.mat']);
end 

