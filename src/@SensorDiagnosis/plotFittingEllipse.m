function plotFittingEllipse(centre,radii,R,sensMeasCell)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

hold on;
plot_ellipsoid(centre(1),centre(2),centre(3),radii(1),radii(2),radii(3),R,'AxesColor','black');
scatter3(sensMeasCell(:,1),sensMeasCell(:,2),sensMeasCell(:,3));
axis equal;
view([30,10]);
xlabel('x (m/s^2)','Fontsize',12);
ylabel('y (m/s^2)','Fontsize',12);
zlabel('z (m/s^2)','Fontsize',12);
hold off;

end

