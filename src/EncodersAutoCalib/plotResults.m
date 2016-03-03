clear all; close all;

load('./data/minimResult_cost1.mat');


figure;

yAcc = [data.ys_10b3_acc;...
        data.ys_10b4_acc;...
        data.ys_10b6_acc;...
        data.ys_10b7_acc;...
        data.ys_10b8_acc;...
        data.ys_10b12_acc];
maxTime = 10;    
    
tMaxIndex = sum(data.time<=10);    
plot(data.time(1:tMaxIndex),yAcc(:, 1:tMaxIndex),'lineWidth',2.0);
axis tight;
grid on;
legend('Acc3','Acc4','Acc6','Acc7','Acc8','Acc12');
xlabel('Time (sec)','Fontsize',12);
ylabel('Acceleration (m/sec^2)','Fontsize',12);
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','./figs/rawAccData');

figure;
bar(mean(optimalDq,2));
xlabel('Joint index','Fontsize',12);
ylabel('Joint offset (rads)','Fontsize',12);
grid on;

hold on;
errorbar(mean(optimalDq,2),std_optDq,'r*','lineWidth',2.5);

legend('Joint offset','Standard deviation');


set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','./figs/optimResult');




