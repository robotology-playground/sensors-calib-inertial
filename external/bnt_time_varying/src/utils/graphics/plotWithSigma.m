function plotWithSigma(t, x, sx, string)

%Francesco Nori
%Genova 18 Dec 2013
%
%This function plots a vector x and its confidence interval given 
%by +/- 2*sx where sx has the same dimensions of x

plot(t, x, string)
hold on
plot(t, x+2*(sx.^(1/2)), strcat(string, '--'))
plot(t, x-2*(sx.^(1/2)), strcat(string, '--'))