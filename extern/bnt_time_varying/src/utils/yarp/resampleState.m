function [q, dq, d2q] = resampleState(t, ts, qs, dqs, d2qs)

q   = interp1(ts, qs'  , t)';
dq  = interp1(ts, dqs' , t)';
d2q = interp1(ts, d2qs', t)';

end