function [PO] = PercentO(AvLife, LUT)
%Calculate percent open in an MT-FLIM image using a LUT. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
sz=size(AvLife);
AL=double(AvLife.*10^9);
PO=zeros(sz(1), sz(2));
for j=1:sz(1)
    for k=1:sz(2)
        [ d, ix ] = min( abs( LUT(2,:)-AL(j,k) ) );
         PO(j,k)=LUT(1,ix);
    
    end
end
%close all
%figure(5);
%imshow(PO,[0 20]);
%disp('Done')
end

