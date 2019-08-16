%This file is used to calculate an illumination profile for the FLIM
%system, as well as to determine whether FLIM background is important (it
%is not). 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Illumination Correction
%Approach: The effect is less obvious w free dye, so I want to use SLB
%data. The challenge is there is noise and sometimes aggregates. Because of
%differences in count rates across samples (kept as close as possible but always some variation, and brighter (more open) probes will emit more photons, it's not simple to just sum a
%bunch and find (I only took like 3 ims per SLB). So, the solution is to
%generate many illumination profiles from different surfaces. Then, average
%10 of these to get a mask which I will apply to my data. I will do this
%with both z3 and z5. In the illumination profile calculation, anything 3SD
%above image mean will be masked out of calc. 
Base='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\CorrectionIms\Illum'
Zooms={'Z3','Z5'};
Surfaces={'I1','I2','I3','I4','I5','I6','I7','I8','I9','I10'};
NormProfile={};
for z=1:2
    for s=1:10
        ImNames{z,s}=FindFiles(fullfile(Base,Zooms{z},Surfaces{s}),'*.tif');
        [NormProfile{z,s}]=IlluminationProfile(ImNames{z,s});
    end
    CorrectionIm{z}=sum(cat(3,NormProfile{z,:}),3)./10;
end
subplot(1,2,1); imshow(CorrectionIm{1},[]);
ScaleBar(CorrectionIm{1},.14,5);
subplot(1,2,2); imshow(CorrectionIm{2},[]);
ScaleBar(CorrectionIm{1},.08,5);
IllumProfz3=CorrectionIm{1};
IllumProfz5=CorrectionIm{2};

%% Noise
% To determine the background contribution I am using the measured photons in 1 min
% aquisition on detector 2 w a 690 laser block. Assumtion is that detectors
% behave similarly. 

%%Mean dark counts ~.28 per pixel --> determine to be negligable. 

DCFold='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\CorrectionIms\Noise';
for j=1:2
DImAdds{j}=FindFiles(fullfile(DCFold,Zooms{j}),'*.tif');
for k=1:3
DIms{j,k}=ImportPQTif(DImAdds{j}{k});
DCT(j,k)=mean(DIms{j,k}(:));
end
end
DC=mean(DCT(:))
DC_SDev=std(DCT(:))
close all
imshow(DIms{1,1}, [0 10]);