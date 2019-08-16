function [fitparams rsq] = LinearFit_Plot(X,Y,C)
%This function will fit data and add a linear fit to the plot along w the
%r^2 value. 
%   Input is x and y data
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
hold on
szX=size(X); szY=size(Y); 
if szX ~= szY; Y=Y'; end
yLim=get(gca,'ylim');
xLim=get(gca,'xlim');
xfitvals=X;
fitparams=polyfit(X,Y,1);
yfitvals=xfitvals.*fitparams(1)+fitparams(2);

yresid=Y-yfitvals;
SSresid = sum(yresid.^2);
SStotal = (length(Y)-1) * var(Y);
rsq = 1 - SSresid/SStotal;
xplot=[0:.1: xLim(2)];
yplot=fitparams(1).*xplot+fitparams(2);
hold on
plot(xplot,yplot,'--','Color',C);
[x y]=ginput(1);
text(x,y,strcat('r^2 = ',num2str(rsq)),'FontName','Arial','FontSize',18)
end

