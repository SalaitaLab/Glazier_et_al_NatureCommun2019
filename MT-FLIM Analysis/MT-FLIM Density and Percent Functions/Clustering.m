function [ProbeDensity] = Clustering(Counts,BAvCts, Percent)
%This will calculate the clustering contribution per pixel
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
I=Counts;
I0=BAvCts;
Q=.78;
b=0;
Percent=Percent/100;

Numerator=I-b;
DenomP1=(I0-b)./(1-Q).*Percent;
DenomP2=(I0-b).*(1-Percent);
ProbeDensity=Numerator./(DenomP1+DenomP2);
end

