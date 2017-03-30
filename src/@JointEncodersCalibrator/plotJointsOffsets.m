function plotJointsOffsets(mean_optDq,std_optDq)

figure;
hold on;

bar(mean_optDq);
errorbar(mean_optDq,std_optDq,'r*','lineWidth',2.5);

grid on;
xlabel('Joint index','Fontsize',12);
ylabel('Joint offset (rads)','Fontsize',12);
legend('Joint offset','Standard deviation');
set(gca,'FontSize',12);

end

