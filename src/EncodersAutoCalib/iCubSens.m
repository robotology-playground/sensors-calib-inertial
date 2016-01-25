function [ ymodel ] = iCubSens( dmodel , sens)
%AUTOSENSSNEA Generates a random sensor distribution articulated rigid body.
%   This function generates a structure that contains all measurements
%   needed to perform sparse inverse dynanmic compuations on the supplied
%   articulated rigid body (dmodel) assuming mutiple (and possibly
%   redudant) senors. The dynamic model is assumed to be in
%   featherstone-like format. The struct has the following fields:
%
%       ny - the number of available sensors
%
%       NB - the number of rigid links in the articulated rigid body
%
%   labels - a (ny,1) cell array containing the type of sensor. Possible type of
%            sensors are listed in the following where the subscript i
%            refers to the i-th link of the articulated rigid body.
%                     - a_i :  spatial accelration
%                     - fB_i:  net spatial force
%                     - f_i:   net sptaial force with parent
%                     - tau_i: joint torque
%                     - fx_i:  external spatial force
%                     - d2q_i: joint acceleration
%
%    sizes - a (ny,1) cell array containing the size of each sensor
%
%        m - the lenght of measurement vetor y (sum of all sizes)
%
%        Y - a (ny,NB) cell array describing the link between the sensors
%            available sensors and the vector of variables d
%            describing the dynamics of the articulated rigid body. In
%            particulat we have:
%                       Y{i,j} d_j = y_i
%            being y_i the i-th measurement and d_j the following vector of
%            dynamic variables associated to the articulated rigid body:
%                       d_j = [a_j, fB_j, f_j, tau_j, fx_j, d2q_j]
%
%       Ys - a sparse representation of the whole-matrix Y
%
% This specific function creates the model for the iCub sensors, which at
% the moment of writing the present function include:
%
%  - F/T sensor in the right/left thigh
%  - F/T sensor in the right/left foot
%  - F/T sensor in the right/left bicep
%  - acc sensor in the right/left foot
%  - acc/gyro in the right/left hand
%  - acc/gyro in the head
%
% Author: Francesco Nori
% Genova, Dec 2014

ymodel.NB = dmodel.NB;
ymodel.ny = 0;

for i = 1 : dmodel.NB
   
   ymodel.ny = ymodel.ny + 1;
   ymodel.sizes{ymodel.ny,1} = 6;
   ymodel.labels{ymodel.ny,1} = [dmodel.linkname{i} '_ftx'];
   for j = 1 : dmodel.NB
      ymodel.Y{ymodel.ny,j}   = zeros(6,26);
      ymodel.Ys{ymodel.ny,j}  = sparse(zeros(6,26));
   end
   ymodel.Y{ymodel.ny,i}  = [zeros(6,6) zeros(6,6) zeros(6, 6) zeros(6,1) eye(6) zeros(6, 1)];
   ymodel.Ys{ymodel.ny,i} = sparse(1:6,20:25,ones(6,1), 6, 26);
end

for i = 1 : dmodel.NB
   ymodel.ny = ymodel.ny + 1;
   ymodel.sizes{ymodel.ny,1} = 1; 
   ymodel.labels{ymodel.ny,1} = [dmodel.linkname{i} '_d2q'];
   for j = 1 : dmodel.NB
      ymodel.Y{ymodel.ny,j}   = zeros(1,26);
      ymodel.Ys{ymodel.ny,j}  = sparse(zeros(1,26));
   end
   ymodel.Y{ymodel.ny,i}  = [zeros(1,6) zeros(1,6) zeros(1, 6) zeros(1, 1) zeros(1,6) eye(1,1)];
   ymodel.Ys{ymodel.ny,i} = sparse(1,26,ones(1,1), 1, 26);
end

for i = 1 : length(sens.parts) 
   sens_label = sens.labels{i};
   if strcmp(sens_label(end-2:end), 'imu') || strcmp(sens_label(end-2:end), 'acc') || strcmp(sens_label(end-2:end), 'fts')
      
      ymodel.ny = ymodel.ny + 1;
      dy = sens.ndof{i};
      ymodel.labels{ymodel.ny,1} = sens.labels{i};
      for j = 1 : dmodel.NB
         ymodel.Y{ymodel.ny,j}   = zeros(dy,26);
         ymodel.Ys{ymodel.ny,j}  = sparse(zeros(dy,26));
         if(strcmp(sens.parts{i}, dmodel.linkname{j}))
            link_ind = j;
         end
      end
      
      if strcmp(ymodel.labels{ymodel.ny,1}(end-2:end), 'imu')
         ymodel.Y{ymodel.ny,link_ind}      = [[zeros(3,3) eye(3); eye(3) zeros(3,3)] zeros(dy,6) zeros(dy,6) zeros(dy, 1) zeros(dy,6) zeros(dy, 1)];
         ymodel.Ys{ymodel.ny,link_ind}     = sparse(1:6,[4:6 1:3],ones(dy,1), dy, 26);
      elseif strcmp(ymodel.labels{ymodel.ny,1}(end-2:end), 'acc')
         ymodel.Y{ymodel.ny,link_ind}      = [zeros(dy,3) eye(dy) zeros(dy,6) zeros(dy,6) zeros(dy, 1) zeros(dy,6) zeros(dy, 1)];
         ymodel.Ys{ymodel.ny,link_ind}     = sparse(1:3,4:6,ones(dy,1), dy, 26);
      elseif strcmp(ymodel.labels{ymodel.ny,1}(end-2:end), 'fts')
         ymodel.Y{ymodel.ny,link_ind}      = [zeros(dy,6) zeros(dy,6) [zeros(3,3) eye(3); eye(3) zeros(3,3)] zeros(dy, 1) zeros(dy,6) zeros(dy, 1)];
         ymodel.Ys{ymodel.ny,link_ind}     = sparse(1:6, [16:18 13:15],ones(dy,1), dy, 26);
      end
      ymodel.sizes{ymodel.ny,1}  = dy;
   end
end


ymodel.m  = sum(cell2mat(ymodel.sizes));

for i = 1 : ymodel.ny
   for j = 1 : ymodel.NB
      Yx{i,j}  = ymodel.Ys{i,j}(:, 1:19);
      Yy{i,j}  = ymodel.Ys{i,j}(:, 20:end);
   end
end

ymodel.Ys = cell2mat([Yx Yy]);
end