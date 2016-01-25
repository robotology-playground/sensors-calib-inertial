function e = costFunctionID(dq, dt, data, myMAP, label_to_min, index_to_min)

NB = myMAP.IDmodel.n;
fx = mat2cell(zeros(6,25), 6, ones(25,1));
d  = zeros(26*NB,1);

for i = 1 : length(data.time)
   
   q0 = data.q(:,i);
   q  = data.q(:,i);
   q(index_to_min) = q0(index_to_min) + dq;
      
   [tau, a, fB, f] = ID( myMAP.IDmodel.modelParams, q, zeros(size(data.dq(:,i))), zeros(size(data.d2q(:,i))), fx);
   for j = 1 : NB
      d((1:26)+(j-1)*26, 1) = [a{j}; fB{j}; f{j}; tau(j,1); fx{j}; zeros(size(data.d2q(j,i)))];
   end
   
   y(:,i) = myMAP.simY(d);
end


% py = [0; cumsum(cell2mat(myMAP.IDsens.sensorsParams.sizes))];
% e = 0;
% for l = 1 : length(label_to_min)
%    for k = 1 : myMAP.IDsens.sensorsParams.ny
%       if strcmp(myMAP.IDsens.sensorsParams.labels{k}, label_to_min{l}) || ...
%             (strcmp(myMAP.IDsens.sensorsParams.labels{k}, 'y_omega13') && strcmp(label_to_min{l}, 'lh_gyr')) || ...
%             (strcmp(myMAP.IDsens.sensorsParams.labels{k}, 'y_omega24') && strcmp(label_to_min{l}, 'rh_gyr'))
%          J = myMAP.IDsens.sensorsParams.sizes{k};
%          I = py(k)+1 : py(k)+J;
%          
% %          figure
% %          plot(data.time, data.y(I,:));
% %          hold on
% %          plot(data.time, y(I,:), '--');
% %          title(strrep(myMAP.IDsens.sensorsParams.labels{k}, '_', '~'));
%          for i = I
%             e = e + (data.y(i,:) - y(i,:))*(data.y(i,:) - y(i,:))';
%          end
%       end
%    end
% end

%Compute indexes of y to be used in the minization
py = [0, cumsum(cell2mat(data.ndof))];
iYmin = [];
for l = 1 : length(label_to_min)
   for k = 1 : length(data.labels)
      if strcmp(data.labels{k}, label_to_min{l}) 
         J = data.ndof{k};
         I = py(k)+1 : py(k)+J;
         iYmin = [I+7*NB, iYmin];
      end
   end
end

e = 0;
for t = dt'
   
   e  = e + ((data.y(iYmin,t) - y(iYmin,t))'*(data.y(iYmin,t) - y(iYmin,t)));
      
end

end