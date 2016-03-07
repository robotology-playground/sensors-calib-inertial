clear; close all;
%% load data from mat files

selInd = 9:14;
selTime = 3;

load('randomOffsets')
qTilde = randOffsets(selInd);

% no offset
load('q_j__noOffset')

%fakeOffset = ans.Data(end,selInd); 
numPts = size(ans.Data,1);
off0Deg.q = ans.Data(:,selInd);
off0Deg.t = ans.Time;
off0Deg.titl = 'Without joint offsets';
load('qd__noOffset');
off0Deg.qd = ans.Data(:,selInd);
off0Deg.err = off0Deg.qd - off0Deg.q;
fakeOffset = off0Deg.err(end,:);
off0Deg.err = off0Deg.err - repmat(fakeOffset,numPts,1);
load('./gOfq__noOffset.mat');
off0Deg.gOfq = ans.Data(:,selInd);
off0Deg.tMaxInd = sum(off0Deg.t<=selTime);
off0Deg.saveName = 'noOffset';

load('./q_j__offSet10deg.mat');
numPts = size(ans.Data,1);
off10Deg.q = ans.Data(:,selInd);
off10Deg.t = ans.Time;
off10Deg.titl = 'Random joint offsets';
load('./qd__offSet10deg.mat');
off10Deg.qd = ans.Data(:,selInd);
off10Deg.err = off10Deg.qd - off10Deg.q;
fakeOffset = off0Deg.err(end,:);
off10Deg.err = off10Deg.err - repmat(fakeOffset,numPts,1);
load('./gOfq__offSet10deg.mat');
off10Deg.gOfq = ans.Data(:,selInd);
off10Deg.tMaxInd = sum(off10Deg.t<=selTime);
off10Deg.saveName = 'randOffset';

testMats = {off0Deg,off10Deg};

for i = 1:length(testMats)
    figure(i);

    plot(testMats{i}.t(1:testMats{i}.tMaxInd),testMats{i}.err(1:testMats{i}.tMaxInd,:),'lineWidth',2.0);
    xlabel('Time (sec)','FontSize',12);
    ylabel('Joint Position (degrees)','FontSize',12);
    hl = legend('e_q_1','e_q_2','e_q_3','e_q_4','e_q_5','e_q_6');
    set(hl,'FontSize',12);
    axis tight;
    grid on;
    %title(testMats{i}.titl,'FontSize',16);
    
    set(gca,'FontSize',12);
    print('-dpng','-r300','-opengl',strcat('./figs/',testMats{i}.saveName));
    %     figure(length(testMats)+i);
% 
%     plot(testMats{i}.t,testMats{i}.gOfq,'lineWidth',2.0);
%     xlabel('Time (sec)');
%     ylabel('Gravity torque (Nm)');
%     legend('\tau_1','\tau_2','\tau_3','\tau_4');
%     axis tight;
%     grid on;
%     title(testMats{i}.titl);
    
%     plot(testMats{i}.t,testMats{i}.qd,'lineWidth',2.0);
%     xlabel('Time (sec)');
%     ylabel('Joint Position desired (degrees)');
%     legend('qd_1','qd_2','qd_3','qd_4');
%     axis tight;
%     grid on;
%     title(testMats{i}.titl);
end
% 
% figure(2);
% hold on; 
% plot(testMats{2}qTild2
