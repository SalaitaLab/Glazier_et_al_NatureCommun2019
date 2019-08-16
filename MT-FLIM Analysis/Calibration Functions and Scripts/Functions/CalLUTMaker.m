function [LUT] = CalLUTMaker(fitparms)
%this function will make a % open Look-Up-Table for MT-FLIM. 
% The generated lookup table is in 5% intervals. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
syms Y X
a=fitparms.a; b=fitparms.b; c=fitparms.c; d=fitparms.d;
 TV=[]; TauVals=[];

    Breaks=linspace(0,100,21);
    for k=1:21
        syms X Y;
Y(X)= a*exp(b*X) + c*exp(d*X);
       TV(k)=Y(Breaks(k));
       TauVals(k)=double(vpa(TV(k)));
    end

TauVals= double(vpa(TV,3));
LUT=[Breaks; TauVals(1,:)];


end

