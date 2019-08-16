function [B, SDB] = Background(IMselect)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This will have the user select 3 ROIs and then will calculate background. 
%   Input is an image. Output is the Background. IMRef is reference like
%   RICM or DIC. ImSelect is the fluorescence image. 

figure(5);
imshow(IMselect,[]); title('Select 3 Background ROIS');
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
Bs=zeros(1,3);
for j=1:3
       coord=getPosition(imrect);
       ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
       rectan=IMselect(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));
       meanIntensity=mean(rectan(:),'omitnan');
    Bs(j)=meanIntensity;
   
end
B=mean(Bs);
SDB= std(Bs);
end

