function e = costFunctionMAP(dq, dt, data, myMAP, myRMAP, label_to_min, label_to_map, index_to_min)

NB = myMAP.IDmodel.n;
y  = zeros(myMAP.IDmeas.m, length(data.time));
e  = zeros(1, length(data.time));

%Compute indexes of y to be used in the minization
py = [0, cumsum(cell2mat(data.ndof))];
iYmin = [];
for l = 1 : length(label_to_min)
   for k = 1 : length(data.labels)
      if strcmp(data.labels{k}, label_to_min{l}) 
         J = data.ndof{k};
         I = py(k)+1 : py(k)+J;
         iYmin = [iYmin, I+7*NB];
      end
   end
end


%Compute indexes of y to be used in the maximum a posteriori estimation
py = [0; cumsum(cell2mat(myRMAP.IDsens.sensorsParams.sizes))];
iYmap = [];
for l = 1 : length(label_to_map)
   for k = 1 : myRMAP.IDsens.sensorsParams.ny
      if strcmp(myRMAP.IDsens.sensorsParams.labels{k}, label_to_map{l}) || ...
            (strcmp(myRMAP.IDsens.sensorsParams.labels{k}, 'y_omega13') && strcmp(label_to_min{l}, 'lh_gyr')) || ...
            (strcmp(myRMAP.IDsens.sensorsParams.labels{k}, 'y_omega24') && strcmp(label_to_min{l}, 'rh_gyr'))
         J = myRMAP.IDsens.sensorsParams.sizes{k};
         I = py(k)+1 : py(k)+J;
         iYmap = [iYmap, I];
      end
   end
end
iYmap = [1:7*myRMAP.IDstate.n, iYmap];

for t = dt'
   
   
   q0 = data.q(:,t);
   q  = data.q(:,t);
   q(index_to_min) = q0(index_to_min) + dq;
   
   %% simulate the output
   myRMAP = myRMAP.setState(q, data.dq(:,t));
   myRMAP = myRMAP.setY(data.y(iYmap,t));
   myRMAP = myRMAP.solveID();   
   
   % myRMAP = myRMAP.setState(data.q(:,i), zeros(size(data.dq(:,i))));
   y(:,t)  = myMAP.simY(myRMAP.d);
   e(1,t)  = ((data.y(iYmin,t) - y(iYmin,t))'*(data.y(iYmin,t) - y(iYmin,t)));
      
end
% for i = iYmin
%    figure
%    plot(data.time, data.y(i,:)')
%    hold on
%    plot(data.time(dt), y(i,dt)', '--')
% end
e  = sum(e,2);


end