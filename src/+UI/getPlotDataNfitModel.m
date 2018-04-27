h=gca
axesObjs=h.Children
[x,y]=getpoints(axesObjs)
axesObjs
model=Regressors.frictionModel2(x',y')
model.theta
[xs,ys] = Regressors.resampleDataModel(model,x',10000);
hold on;
plot(xs,ys,'r','lineWidth',4.0);
