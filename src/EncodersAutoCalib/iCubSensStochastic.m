function [ model ] = iCubSensStochastic( model )
%AUTOSENSSTOCHASTIC Add stochastic component to a sensor distribution
%   This function takes a structure containing sensor distribution (similar
%   to the one created by autoSensSNEA) and adds to the structure some
%   fields that are used to represent the variance of the measurements. The
%   sensor model is the following:
%
%                 Y(q,dq) d = y
%
%   and the variance is associated with the confidence on the measurement
%   equation.


idSy_inv = []; jdSy_inv = []; dSy_inv=[];
my = 1;

%uncertainties
so       = 0.07; 
sa       = 0.05;
sf       = 10;
su       = 0.031;
sd       = 0.2;

imuS   = [sa*eye(3) zeros(3,3); zeros(3,3) so*eye(3)];
ftsS   = [sf*eye(3) zeros(3,3); zeros(3,3) su*eye(3)];
accS   = imuS(1:3, 1:3);
ftxS   = ftsS.*1e-4;
d2qS   = sd;
qS     = 0.05*pi/180;
dqS    = 0.01;
omegaS = so*eye(3);

for i = 1 : model.ny
   dy = model.sizes{i,1};
   if strcmp(model.labels{i}(end-2:end), 'imu')
      model.Sy{i,1} = imuS;
   elseif strcmp(model.labels{i}(end-2:end), 'fts')
      model.Sy{i,1} = ftsS;
   elseif strcmp(model.labels{i}(end-2:end), 'acc')
      model.Sy{i,1} = accS;
   elseif strcmp(model.labels{i}(end-2:end), 'ftx')
      model.Sy{i,1} = ftxS;
   elseif strcmp(model.labels{i}(end-2:end), 'd2q')
      model.Sy{i,1} = d2qS;      
   elseif length(model.labels{i}) >= 3 && strcmp(model.labels{i}(1:3), 'y_q')
      model.Sy{i,1} = qS;
   elseif length(model.labels{i}) >= 4 && strcmp(model.labels{i}(1:4), 'y_dq')
      model.Sy{i,1} = dqS;
   elseif length(model.labels{i}) >= 7 && strcmp(model.labels{i}(1:7), 'y_omega')
      model.Sy{i,1} = omegaS;                  
   end
      
      
   [ii, jj, ss] = placeSubmatrixSparse(my, my, inv(model.Sy{i,1}));
   idSy_inv = [idSy_inv; ii];
   jdSy_inv = [jdSy_inv; jj];
   dSy_inv  = [dSy_inv;  ss];
   my = my + dy;
end

iSy_s = cell2mat(model.sizes);
jSy_s = cell2mat(model.sizes);
model.Sy_inv = submatrixSparse(iSy_s, jSy_s, (1:length(iSy_s))', (1:length(jSy_s))');

for i = 1 : model.ny
   % model.Sy{i,1} = sMeas.*generateSPDmatrix(dy);
   % S = inv(model.Sy{i,1});
   S = model.Sy{i,1};
   model.Sy_inv = set(model.Sy_inv, inv(S), i, i);
end


end
