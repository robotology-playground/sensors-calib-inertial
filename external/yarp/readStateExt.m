function [q, dq, d2q, dqM, tau, pwm, time] = readStateExt(n, filename)

% n is the number of joints in the limb (6 for a leg, 7? for the arm, ...)

format = '%d %f ';
fid    = fopen(filename);

for j = 1 : 11
   format = [format, '('];
   for i = 1 : n
      if j < 10
         format = [format, '%f '];
      else
         format = [format, '%d '];
      end
   end
   if ismember(j,[1 2 3 5 7 8])
       format = [format, ') [ok] '];
   else
       format = [format, ') %*s '];
   end
end

% parse file into an array of cells. As all file lines (L lines) have the same
% format, textscan parses the j_th matched elements of every line into one
% single cell C(1,j) = matrix(Lx1).
C    = textscan(fid, format);
% 2nd column is defined as C{1,2} and will be a column vector of
% timestamps.
time = C{1, 2};
q    = cell2mat(C(1, 3    :3+  n-1)); % n columns of "joint q" value
dq   = cell2mat(C(1, 3+  n:3+2*n-1)); % n columns of "joint dq" value
d2q  = cell2mat(C(1, 3+2*n:3+3*n-1)); % n columns of "joint d2q" value
dqM  = cell2mat(C(1, 3+4*n:3+5*n-1)); % n columns of "motor dq" value
tau  = cell2mat(C(1, 3+6*n:3+7*n-1)); % n columns of "joint tau" ("torques") value
pwm  = cell2mat(C(1, 3+7*n:3+8*n-1)); % n columns of "motor pwm" ("pwmDutycycle") value

[tu,iu] = unique(time);
time    = tu';
q       = q(iu, :)';
dq      = dq(iu, :)';
d2q     = d2q(iu, :)';
dqM     = dqM(iu, :)';
tau     = tau(iu, :)';
pwm     = pwm(iu, :)';

if fclose(fid) == -1
   error('[ERROR] there was a problem in closing the file')
end
