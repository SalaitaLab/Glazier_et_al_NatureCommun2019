function [  ] = ScaleBarBlack( image1, PixSz, Length )
%Will draw a scalebar.% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%   PixSz is the size per pixel.
BarWidth= Length/PixSz;
hold on;
% plot a scale bar in black first
BarHeight = 2;
xPos = size(image1,2)*0.85 - BarWidth;
yPos = size(image1,1)*0.85 - BarHeight;
textCenterX = xPos + floor(BarWidth/2);
textCenterY = yPos + BarHeight*5;
rectPosition = [xPos, yPos, BarWidth, BarHeight]
hRect = rectangle('Position', rectPosition);

% label the scale bar
%str = strcat(num2str(Length),' microns');
%hText = text(textCenterX,textCenterY,str);
%set(hText,'HorizontalAlignment','center');
%}

    set(hRect,'EdgeColor','k');
    set(hRect,'FaceColor','k');
  % set(hText,'Color','k','FontName','Arial','FontSize',14);
%}


end

