function [meantau, HistoCell, GFit] = ProcessPercOpen(FN)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is folder w triplicate histogram .dat files. Output is average
%lifetime matrix. 
%  
FNames= FindFiles(FN,'*.dat')
for j=1:length(FNames);
    Order=floor((j-1)/3)+1;
    Spot=rem(j,3)+1;
    Imp=importdata(FNames{j});
    HistoCell{Order,Spot}=Imp.data;
    GF=fit(HistoCell{Order,Spot}(:,1), HistoCell{Order,Spot}(:,2),'gauss1')
   GFit{Order,Spot}=GF;
    z=double(GF.b1);
    meantau(Order, Spot)= z;
end
end

