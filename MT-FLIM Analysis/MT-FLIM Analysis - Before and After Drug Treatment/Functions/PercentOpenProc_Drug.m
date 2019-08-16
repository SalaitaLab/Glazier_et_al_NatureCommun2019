function [MeanPercent, MeanLine, MedLine] = PercentOpenProc_Drug(DrugCellArray)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This function is used to generate change in percent open podosome region
%plots like those shown in Figure 4. The input is a cell array of before
%and after PodImages. Output is a matrix of the percent open values.
%Mean and MedLine are the means and medians, respectively. 
%   
MeanPercent=[];
for t=1:2 % Pre or Post
    for c=1:length(DrugCellArray)
    MeanPercent(t,c)= DrugCellArray{t,c}.MeanPercent;
    end
    MeanLine(t)=mean(MeanPercent(t,:),'omitnan');
    MedLine(t)=median(MeanPercent(t,:),'omitnan');
end
end

