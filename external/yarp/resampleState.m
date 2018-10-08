function [q, dq, d2q] = resampleState(t, ts, qs, dqs, d2qs)
if size(qs,1)==length(ts)
    q   = interp1(ts, qs  , t);
    dq  = interp1(ts, dqs , t);
    d2q = interp1(ts, d2qs, t);
else
    q   = interp1(ts, qs'  , t);
    dq  = interp1(ts, dqs' , t);
    d2q = interp1(ts, d2qs', t);
end
end