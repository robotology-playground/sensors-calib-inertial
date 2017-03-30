function [ obj ] = initSparseMatrixIndices( obj )
%INITSPARSEINDICES Summary of this function goes here
%   Detailed explanation goes here

obj.ibs = zeros(12*obj.IDmodel.modelParams.NB, 1);
obj.bs  = zeros(12*obj.IDmodel.modelParams.NB, 1);

nDi = 0;
for i = 1:obj.IDmodel.modelParams.NB
   if obj.IDmodel.modelParams.parent(i) == 0
      nDi = nDi + 6  + 6*obj.IDmodel.jn(i); %a_i
   else
      nDi = nDi + 36 + 6 + 6*obj.IDmodel.jn(i); %a_i
   end
   nDi = nDi + 36 + 6 + ... %fB_i
      6  + 6 + 36 + 36*length(obj.IDmodel.sparseParams.ind_j{i}) + ... %f_i
      6  + obj.IDmodel.jn(i); %tau_i
end
obj.iDs = zeros(nDi, 1);
obj.jDs = zeros(nDi, 1);
obj.Ds  = zeros(nDi, 1);

pD = 1;  

for i = 1:obj.IDmodel.modelParams.NB
   if obj.IDmodel.modelParams.parent(i) == 0
      % a{i} = obj.Xup{i}*(-a_grav) + obj.IDmodel.S{i}*qdd(i);
      % D1  = [-eye(6) zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) obj.IDmodel.S{i}];
      % b1  = obj.Xup{i}*(-a_grav);
      obj.ibs((i-1)*12+1: (i-1)*12+6, 1)  = (i-1)*19+1: (i-1)*19+6;
      
      obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD11(1:6:36,i,i)+[0 1 2 3 4 5]';
      obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD11(1:6:36,i,i);
      pD = pD + 6;
      
      obj.iDs (pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.sparseParams.iD16(:,i,i);
      obj.jDs (pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.sparseParams.jD16(:,i,i);
      pD = pD + obj.IDmodel.jn(i)*6;
   else
      % a{i} = ... + obj.IDmodel.S{i}*qdd(i) + crm(obj.v(:,i))*vJ;
      % vJ = obj.IDmodel.S{i}*qd(i);
      % D1 = [-eye(6) zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) obj.IDmodel.S{i}];
      % b1 = crm(obj.v(:,i))*vJ;
      
      obj.ibs((i-1)*12+1: (i-1)*12+6, 1)     = (i-1)*19+1: (i-1)*19+6;
      
      obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD11(1:6:36,i,i)+[0 1 2 3 4 5]';
      obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD11(1:6:36,i,i);
      pD = pD + 6;
      
      obj.iDs (pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.sparseParams.iD16(:,i,i);
      obj.jDs (pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.sparseParams.jD16(:,i,i);
      pD = pD + obj.IDmodel.jn(i)*6;
      % a{i} = obj.Xup{i}*a{obj.IDmodel.modelParams.parent(i)} + ...
      % Dc{i, obj.IDmodel.modelParams.parent(i)} = [ obj.Xup{i} zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))
      %     zeros(12+obj.jn(i), 24+2*obj.jn(i))];
      
      j = obj.IDmodel.modelParams.parent(i);
      obj.iDs (pD: pD+35, 1) = obj.IDmodel.sparseParams.iD11(:,j,i);
      obj.jDs (pD: pD+35, 1) = obj.IDmodel.sparseParams.jD11(:,j,i);
      pD = pD + 36;
      
   end
   % fB{i} = obj.IDmodel.modelParams.I{i}*a{i} + crf(obj.v(:,i))*obj.IDmodel.modelParams.I{i}*obj.v(:,i);
   % D2 = [obj.IDmodel.modelParams.I{i} -eye(6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))];
   % b2 = crf(obj.v(:,i))*obj.IDmodel.modelParams.I{i}*obj.v(:,i);
   
   obj.ibs((i-1)*12+7: i*12, 1)  = (i-1)*19+7: (i-1)*19+12;
   
   obj.iDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.iD21(:,i,i);
   obj.jDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.jD21(:,i,i);
   pD = pD + 36;
   
   obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD22(1:6:36,i,i)+[0 1 2 3 4 5]';
   obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD22(1:6:36,i,i);
   pD = pD + 6;
   
   % f{i} = fB{i} - obj.Xa{i}' \ f_ext{i};
   % f{obj.IDmodel.modelParams.parent(j)} = f{obj.IDmodel.modelParams.parent(j)} + obj.Xup{j}'*f{j};
   % D3 = [zeros(6,6) eye(6) -eye(6) zeros(6, obj.jn(i)) -inv(obj.Xa{i}') zeros(6, obj.jn(i))];
   % b3 = zeros(6,1);
   
   obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD32(1:6:36,i,i)+[0 1 2 3 4 5]';
   obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD32(1:6:36,i,i);
   pD = pD + 6;
   
   obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD33(1:6:36,i,i)+[0 1 2 3 4 5]';
   obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD33(1:6:36,i,i);
   pD = pD + 6;
   
   obj.iDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.iD35(:,i,i);
   obj.jDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.jD35(:,i,i);
   pD = pD + 36;
   
   % tau(i,1) = obj.IDmodel.S{i}' * f{i};
   % D4 = [zeros(obj.jn(i), 6) zeros(obj.jn(i), 6) obj.IDmodel.S{i}' -eye(obj.jn(i)) zeros(obj.jn(i), 6) zeros(obj.jn(i), obj.jn(i))];
   % b4 =  zeros(obj.jn(i), 1);
   
   obj.iDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.iD43(:,i,i);
   obj.jDs (pD : pD+5, 1) = obj.IDmodel.sparseParams.jD43(:,i,i);
   pD = pD + 6*obj.IDmodel.jn(i);
   
   obj.iDs (pD : pD+obj.IDmodel.jn(i)-1, 1) = obj.IDmodel.sparseParams.iD44(:,i,i);
   obj.jDs (pD : pD+obj.IDmodel.jn(i)-1, 1) = obj.IDmodel.sparseParams.jD44(:,i,i);
   pD = pD + obj.IDmodel.jn(i);
   
   for j = obj.IDmodel.sparseParams.ind_j{i}
      % f{obj.IDmodel.modelParams.parent(j)} = f{obj.IDmodel.modelParams.parent(j)} + obj.Xup{j}'*f{j};
      % Dc{i,j} = [ zeros(12, 24+2*obj.jn(i))
      %     zeros(6,6) zeros(6,6) obj.Xup{j}' zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))
      %     zeros(obj.jn(i), 24+2*obj.jn(i))];
      
      obj.iDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.iD33(:,j,i);
      obj.jDs (pD : pD+35, 1) = obj.IDmodel.sparseParams.jD33(:,j,i);
      pD = pD + 36;
   end
end

for i = 1:obj.IDmodel.modelParams.NB
   for j = 1 : 6
      obj.iLabels{(i-1)*19+j} = ['a_'   num2str(i)];
   end
   for j = 6 + (1 : 6)
      obj.iLabels{(i-1)*19+j} = ['fB_'  num2str(i)];
   end
   for j = 12 + (1 : 6)
      obj.iLabels{(i-1)*19+j} = ['f_'   num2str(i)];
   end   
   obj.iLabels{(i-1)*19+19} = ['tau_' num2str(i)];
   
   obj.iIndex((i-1)*4+1:4*i,1) = [(i-1)*19+1; (i-1)*19+7; (i-1)*19+13; (i-1)*19+19];
end

% d - dynamic varaibles [a_i, fB_i, f_i, tau_i, fx_i, d2q_i]

for i = 1:obj.IDmodel.modelParams.NB
   for j = 1 : 6
      obj.jLabels{(i-1)*26+j} = ['a_'   num2str(i)];
   end
   for j = 6 + (1 : 6)
      obj.jLabels{(i-1)*26+j} = ['fB_'  num2str(i)];
   end
   for j = 12 + (1 : 6)
      obj.jLabels{(i-1)*26+j} = ['f_'   num2str(i)];
   end   
   obj.jLabels{(i-1)*26+19} = ['tau_' num2str(i)];
   for j = 19 + (1 : 6)
      obj.jLabels{(i-1)*26+j} = ['fx_'  num2str(i)];
   end
   obj.jLabels{(i-1)*26+26} = ['d2q_' num2str(i)];
   
   obj.jIndex((i-1)*6+1:6*i,1) = [(i-1)*26+1; (i-1)*26+7; (i-1)*26+13; (i-1)*26+19; (i-1)*26+20; (i-1)*26+26];
end
