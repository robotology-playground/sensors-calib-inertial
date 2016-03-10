%% clear all variables and close all previous figures
clear
close all
clc

%% define load parameters

part = 'left_leg'
dataPath = '../../data/calibration/dumper/iCubGenova02_#1/';
file = [dataPath part '/' 'stateExt:o' '/data.log'];
timePlotMin = 132;
timePlotMax = 150; % max index before any of the joints decelerates
qList = 1:6;
colorstr='rgbcym';

%% load data
[q,dq,d2q,t] = readStateExt(6,file);

tmin = min(t);
t = t - tmin;
timePlotMinIndex = sum(t<timePlotMin);
timePlotMaxIndex = sum(t<timePlotMax);
% timePlotMinIndex = 1;
% timePlotMaxIndex = length(t);

%% plot data
figure;
hold on;
for iter = qList
    plot(t(timePlotMinIndex:timePlotMaxIndex),q(iter,timePlotMinIndex:timePlotMaxIndex),['-' colorstr(iter)],'linewidth',2.0);
    plot(t(timePlotMinIndex:timePlotMaxIndex),dq(iter,timePlotMinIndex:timePlotMaxIndex),['--' colorstr(iter)],'linewidth',1.0);
    bar(t(timePlotMinIndex:timePlotMaxIndex),d2q(iter,timePlotMinIndex:timePlotMaxIndex));
end
axis tight;
grid on;
legend('q(t)','dq(t)','d2q(t): bar','Location','NorthEastOutside');
xlabel('Time (sec)','Fontsize',12);
ylabel('Joint q & dq & d2q','Fontsize',12);
print('-dpng','-r300','-opengl','./figs/selectDataRange_left_leg_allDofs_movingQfwrd');
save './data/selectDataRange_left_leg_allDofs_movingQfwrd.mat';

% we choose time range from 130s to 140s.
