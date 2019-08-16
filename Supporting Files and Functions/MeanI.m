function [ meanIntensity deviation rectan ROIcoords] = MeanI( Image )
%This function will get the mean intensity of an image
%   Input is an image. Output is the mean intensity. You select a region. 
       % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
       
     figure('units','normalized','outerposition',[0 0 1 1]);
       imshow(Image,[]); colormap(gray);
    %  set(gcf, 'Position', get(0, 'Screensize'));
       
       coord=getPosition(imrect);
       ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
       rectan=Image(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));
       meanIntensity=mean(rectan(:),'omitnan');
       deviation=std(rectan(:),'omitnan');
end

