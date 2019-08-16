function [NormProfile, zercheck] = IlluminationProfile(Ims)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is folder w n images 
%Output is normalized image to divide your image by. 
NumMat=zeros(512);
for l=1:length(Ims)
    Cts{l}=ImportPQTif(Ims{l,1});
    M=mean(Cts{l}(:)); S=std(Cts{l}(:));
    Cts{l}(Cts{l}>M+3*S)=0;
    Cts{l}(Cts{l}<M-3*S)=0;
    subplot(1,3,l); imshow(Cts{l},[]);
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

