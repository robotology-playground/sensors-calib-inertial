function obj   = initSparseMatrix(obj)

pD = 1;

for i = 1:obj.IDmodel.modelParams.NB  
  if obj.IDmodel.modelParams.parent(i) == 0
    % a{i} = obj.Xup{i}*(-a_grav) + obj.IDmodel.S{i}*qdd(i);
    % D1  = [-eye(6) zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) obj.IDmodel.S{i}];
    % b1  = obj.Xup{i}*(-a_grav);
    % obj.bs((i-1)*12+1: (i-1)*12+6, 1) = obj.Xup{i}*(-obj.IDmodel.g);

    obj.Ds(pD : pD+5, 1) = -1*ones(6,1);
    pD = pD + 6;
    
    obj.Ds(pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.S{i};
    pD = pD + obj.IDmodel.jn(i)*6;
  else
    % a{i} = ... + obj.IDmodel.S{i}*qdd(i) + crm(obj.v(:,i))*vJ;
    % vJ = obj.IDmodel.S{i}*qd(i);
    % D1 = [-eye(6) zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) obj.IDmodel.S{i}];
    % b1 = crm(obj.v(:,i))*vJ;
    
    % obj.bs((i-1)*12+1: (i-1)*12+6, 1)    = crm(obj.v(:,i))*obj.vJ(:,i);
    
    obj.Ds(pD : pD+5, 1) = -1*ones(6,1);
    pD = pD + 6;
    
    obj.Ds(pD: pD+obj.IDmodel.jn(i)*6-1, 1) = obj.IDmodel.S{i};
    pD = pD + obj.IDmodel.jn(i)*6;
    % a{i} = obj.Xup{i}*a{obj.IDmodel.modelParams.parent(i)} + ...
    % Dc{i, obj.IDmodel.modelParams.parent(i)} = [ obj.Xup{i} zeros(6,6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))
    %     zeros(12+obj.jn(i), 24+2*obj.jn(i))];
    
    % obj.Ds(pD: pD+35, 1) = obj.Xup{i}(:);
    pD = pD + 36;    

  end
  % fB{i} = obj.IDmodel.modelParams.I{i}*a{i} + crf(obj.v(:,i))*obj.IDmodel.modelParams.I{i}*obj.v(:,i);
  % D2 = [obj.IDmodel.modelParams.I{i} -eye(6) zeros(6,6) zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))];
  % b2 = crf(obj.v(:,i))*obj.IDmodel.modelParams.I{i}*obj.v(:,i);
  
  % obj.bs((i-1)*12+7: i*12, 1) = crf(obj.v(:,i))*obj.IDmodel.modelParams.I{i}*obj.v(:,i);

  obj.Ds(pD : pD+35, 1) = obj.IDmodel.modelParams.I{i}(:);
  pD = pD + 36;
  
  obj.Ds(pD : pD+5, 1) = -1*ones(6,1);
  pD = pD + 6;
  
  % f{i} = fB{i} - obj.Xa{i}' \ f_ext{i};
  % f{obj.IDmodel.modelParams.parent(j)} = f{obj.IDmodel.modelParams.parent(j)} + obj.Xup{j}'*f{j};
  % D3 = [zeros(6,6) eye(6) -eye(6) zeros(6, obj.jn(i)) -inv(obj.Xa{i}') zeros(6, obj.jn(i))];
  % b3 = zeros(6,1);
  
  % A  = -inv(obj.Xa{i}');

  obj.Ds(pD : pD+5, 1) = 1*ones(6,1);
  pD = pD + 6;

  obj.Ds(pD : pD+5, 1) = -1*ones(6,1);
  pD = pD + 6;

  % obj.Ds(pD : pD+35, 1) = A(:);
  pD = pD + 36;
    
  % tau(i,1) = obj.IDmodel.S{i}' * f{i};
  % D4 = [zeros(obj.jn(i), 6) zeros(obj.jn(i), 6) obj.IDmodel.S{i}' -eye(obj.jn(i)) zeros(obj.jn(i), 6) zeros(obj.jn(i), obj.jn(i))];
  % b4 =  zeros(obj.jn(i), 1);
  
  obj.Ds(pD : pD+5, 1) = obj.IDmodel.S{i}';
  pD = pD + 6*obj.IDmodel.jn(i);
  
  obj.Ds(pD : pD+obj.IDmodel.jn(i)-1, 1) = -ones(1,obj.IDmodel.jn(i));
  pD = pD + obj.IDmodel.jn(i);

  for j = obj.IDmodel.sparseParams.ind_j{i}
    % f{obj.IDmodel.modelParams.parent(j)} = f{obj.IDmodel.modelParams.parent(j)} + obj.Xup{j}'*f{j};
    % Dc{i,j} = [ zeros(12, 24+2*obj.jn(i))
    %     zeros(6,6) zeros(6,6) obj.Xup{j}' zeros(6, obj.jn(i)) zeros(6,6) zeros(6, obj.jn(i))
    %     zeros(obj.jn(i), 24+2*obj.jn(i))];
    
    % A       = obj.Xup{j}';
    
    % obj.Ds(pD : pD+35, 1) = A(:);
    pD = pD + 36;
  end
end