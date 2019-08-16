function [AlphaMask, DarkIm] = AlphaPodMask25(Cts)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This will black out the podosome cores
%   AvLife should already be plotted. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
figure(89);
AlphaMask =zeros(size(Cts)); 

AlphaMask=Cts;
imshow(AlphaMask,[]);

DarkIm=cat(3, zeros(512), zeros(512), zeros(512));
end

