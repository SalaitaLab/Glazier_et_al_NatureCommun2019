function [ meanIntensity mDevs ROIcoords] = MeanIOnly( Image, min, max )
%This function will get the mean intensity of an image
%   Input is an image. Output is the mean intensity. You select a region. % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
     
       coord=getPosition(imrect);
       ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
       rectan=double(Image(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2)));
       meanIntensity=mean(rectan(:),'omitnan');
       mDevs=std(rectan(:),'omitnan');
end

