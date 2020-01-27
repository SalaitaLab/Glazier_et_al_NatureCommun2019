function [NormProfile, zercheck] = IlluminationProfile20200127(ImFold)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is folder w 3 images from same surface (Since this does not normalize before adding, the images should be similar in their intensity). We used this on 10 surfaces total in script.  
%Output is normalized image to divide your image by. 
NumMat=zeros(512);
Ims= FindFiles(ImFold,'*.tif');
for l=1:length(Ims)
    Cts{l}=ImportPQTif(Ims{l,1});
    M=mean(Cts{l}(:)); S=std(Cts{l}(:));
    Cts{l}(Cts{l}>M+3*S)=0;
    Cts{l}(Cts{l}<M-3*S)=0;
%    subplot(1,3,l); imshow(Cts{l},[]);
    NumMat=NumMat+ (Cts{l}~=0);
end
close
Tot=Cts{1}+Cts{2}+Cts{3};

Mean=Tot./NumMat;
M=max(Mean(:));

NormProfile=Mean/M;
zercheck=any(any(~NormProfile));
%imshow(NormProfile,[]); pause(3);
end

