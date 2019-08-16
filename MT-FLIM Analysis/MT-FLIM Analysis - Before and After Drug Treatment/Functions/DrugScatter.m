function [  ] = DrugScatter(Mat, MedorMean,  ylimo)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This function plots the change in mean percen open before and after drug
%treatment.

% Input is the matrix containing the percent open before and after drug
% treatment.
% MedorMean is the line you would like to draw (median or mean). I suggest
% statistics in GraphPadPrism
% ylimo is the maximum ylimit. 
close all
hold on;
L=length(Mat);
Mat(isnan(Mat))=0;
X= [ones(1,L), ones(1,L).*2];
for j=1:2
plot([j-.3 j+.3],[MedorMean(j) MedorMean(j)],'Color',[.6 .6 .6],'LineWidth',2);
end
for j=1:length(Mat);
    j
    if Mat(j,1)==0 && Mat(j,2)==0
        
        Mat(j,:)=nan;
    end
    if Mat(j,1)>Mat(j,2)
        c{j}='r';
    elseif Mat(j,1)<Mat(j,2)
        c{j}='b';
    else
        c{j}='k';
    end
end
scatter(X, [Mat(:,1); Mat(:,2)],150, '.k');
hold on
for j=1:length(Mat)
plot([1 2], [Mat(j,1), Mat(j,2)],c{j});
end
ylim([0 ylimo])
xlim([0 3]);



xticks([1 2])
xticklabels({'Pre','Post'})

set(gca,'FontSize',14,'FontName','Arial')
ylabel('Percent Open (%)','FontSize',14,'FontName','Arial');
hold on;

plot([1 2], [max(Mat(:))*1.1 max(Mat(:)*1.1)],'-k');

end
