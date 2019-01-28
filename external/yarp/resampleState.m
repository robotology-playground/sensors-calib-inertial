function [qs, dqs, d2qs, dqMs, taus, pwms, curr] = resampleState(ts, t, q, dq, d2q, dqM, tau, pwm, curr)

qs   = interp1(t, q'  , ts);
dqs  = interp1(t, dq' , ts);
d2qs = interp1(t, d2q', ts);
dqMs = interp1(t, dqM', ts);
taus = interp1(t, tau', ts);
pwms = interp1(t, pwm', ts);
curr = interp1(t, curr', ts);

end