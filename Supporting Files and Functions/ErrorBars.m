function [ ] = ErrorBars( DataSet, ErrorMatrix,  ColorMatrix, Labelegend )
%This function can be used to add error bars to a MatLab plot 
%   Error matrix contains the errors for each bar in order. Color matrix
%   specifies the color of each bar in [.X .Y .Z; .X2 .Y2 .Z2...] form. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
hold on;
for D=1:length(ErrorMatrix);
    b=bar(D,DataSet(D),.3,'FaceColor',ColorMatrix(D,:));
end
hold on
for k=1:length(ErrorMatrix);
   % b.CData=ColorMatrix(j,:);
    plot([k-.05 k+.05],[ErrorMatrix(k)+DataSet(k) ErrorMatrix(k)+DataSet(k)],'k','LineWidth',.7);
    plot([k k],[DataSet(k) (DataSet(k)+ErrorMatrix(k))],'k','LineWidth',.7);
    %b.FaceColor='flat'; b.CData(j,:) = ColorMatrix(j,:);
end
   set(gca, 'XTick',[1 2 3 4 5]);
   set(gca, 'XTickLabel',Labelegend);
   legend(Labelegend,'EdgeColor',[1 1 1]);
  

end

