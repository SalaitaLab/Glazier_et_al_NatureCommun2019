function [YPadded] = PaddedBoxPlot2(Y)
%This will prepare data for plotting with boxplot. Y is a cell with all the
%Y data. Each group is a column. % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
YPadded=Y;
l=length(Y);

for j=1:l
    DPts(j)=length(Y{j});
end

for j=1:l
    NanVect=[];
    if DPts(j) ~=max(DPts)
        diff=max(DPts)-DPts(j);
       NanVect=ones(diff,1).*nan;
       size(NanVect)
      size(Y{1,j})
       YPadded{j}=[Y{1,j}; NanVect];
       size(YPadded{j});
       YPadded{j}=YPadded{j};
       SZ=size(YPadded{j})
       
      if SZ(2)<SZ(1)
          YPadded{j}=YPadded{j}
    end
    
end


end

