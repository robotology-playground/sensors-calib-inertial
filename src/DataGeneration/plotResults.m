clear all;
close all;

load('./data/gridResults1_q1-4-5.mat');

figure('Name',num2str(offsetedQsIdxs,'2-D cost Dq%i, Dq%i, Dq%i'));

% length of the 3rd (last) dimension
lengthDim3 = size(offsetsConfigGrid.grid{1},3);

for iter = 1:lengthDim3
    % define the subplots
    subplotLines = floor(sqrt(lengthDim3));
    subplotColumns = ceil(lengthDim3/subplotLines);
    subplot(subplotLines,subplotColumns,iter);
    
    % min of current plot
    minCurrentCost = min(min(e(:,:,iter)));
    
    % plot all costs, the min (black line), and a reference fixed cost
    % of 100 (dotted line)
    hold on;
    contour3(offsetsConfigGrid.grid{1}(:,:,iter)*(180/pi),offsetsConfigGrid.grid{2}(:,:,iter)*(180/pi), ...
        e(:,:,iter),0:10:1600);
    contour(offsetsConfigGrid.grid{1}(:,:,iter)*(180/pi),offsetsConfigGrid.grid{2}(:,:,iter)*(180/pi), ...
        e(:,:,iter),[minCurrentCost+1,minCurrentCost+1],'k-','LineWidth',2);
    contour(offsetsConfigGrid.grid{1}(:,:,iter)*(180/pi),offsetsConfigGrid.grid{2}(:,:,iter)*(180/pi), ...
        e(:,:,iter),[100,100],'r--','LineWidth',2);
    hold off;
    
    % formatting...
    axis tight;
    grid on;
    legend('all costs','cost=min','cost=100');
    xlabel(num2str(offsetedQsIdxs(1),'Offsets Dq%i (degrees)'),'Fontsize',12);
    ylabel(num2str(offsetedQsIdxs(2),'Offsets Dq%i (degrees)'),'Fontsize',12);
    zlabel(num2str(offsetedQsIdxs(3),'Offsets Dq%i (degrees)'),'Fontsize',12);
    set(gca,'FontSize',12);
    title(num2str([offsetedQsIdxs(3) offsetsConfigGrid.grid{1}(iter)],'Offset Dq%i = %f'));
end

print('-dpng','-r300','-opengl',num2str(offsetedQsIdxs,'./figs/2-Dcost_fof_Dq%i-%i-%i'));
