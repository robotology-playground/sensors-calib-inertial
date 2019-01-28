h=gca;
axesObjs=h.Children;

switch class(axesObjs(2))
    case 'matlab.graphics.chart.primitive.Scatter'
        x = axesObjs(2).XData;
        y = axesObjs(2).YData;
        
    case 'matlab.graphics.chart.primitive.animatedline'
        [x,y]=getpoints(axesObjs(2));
    otherwise
end

axesObjs
model=Regressors.frictionModel2(x',y')
% model=Regressors.frictionModel1Sym(x',y')
model.theta
[xs,ys] = Regressors.resampleDataModel(model,x',10000);
hold on;
plot(xs,ys,'c','lineWidth',4.0);
