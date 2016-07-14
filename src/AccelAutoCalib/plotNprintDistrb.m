function plotNprintDistrb(dOrient)
% Plots data in the active figure
%
histogram(dOrient,200,'Normalization','probability');
xlabel('Oriented distance to surface','Fontsize',12);
ylabel('Normalized number of occurence','Fontsize',12);

fprintf(['distribution of distances to a centered sphere\n'...
    'mean:%d\n'...
    'standard deviation:%d\n'],mean(dOrient,1),std(dOrient,1,1));

end

