function [D_mean D_SEM DS1 DS2 DS3] = SLBFRAP(FileAddress, Folders, PixSz)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
% This will calculate the diffusion coefficient of your SLB given 3 FRAPS each on triplicate SLBs. PixSz is the
% pixel size in microns. 
% Outputs are the mean diffusion coefficinet, standard error of the mean,
% and the individual surface diffusion coefficients. 

% Read in data
for j=1:2
DatNames= FindFiles(fullfile(FileAddress,Folders{j}),'*.nd2');
for k=1:length(DatNames)
    ND2{j,k}=bfopen(DatNames{k});
end
end

% Background subtract and normalize data
for k=1:length(ND2)
  %  BSStacks{k,1}=double(ND2{1,k}{1,1}{1,1}-200);
    for t=1:7
        BSStacks{k,t}=double(ND2{2,k}{1,1}{t}-200);
    end
    Imax{k}=Background(double(ND2{1,k}{1,1}{1,1})-200);
   
    for t=1:7
        Norm{k,t}=BSStacks{k,t}./Imax{k};
        close
    end
end

% Find locate bleached region and perform calculations
close all
hold on
for k=1:9
    Mask{k}=Norm{k,1}<.5;
    Mask{k}=bwareaopen(Mask{k},100);
    
    RP=regionprops('table',Mask{k},'Centroid','MajorAxisLength','MinorAxisLength');
   w(k)=mean([RP.MajorAxisLength, RP.MinorAxisLength],2)/2;

    for t=1:7
        ROI=Mask{k}.*Norm{k,t};
        ROI(ROI==0)=NaN;,
        I(k,t)=mean(ROI(:),'omitnan');
    end
    fitresult{k}=FitDData([0:6].*30, I(k,:));
    thalf{k}=fitresult{k}.T*log(2);
    D(k)=.88*(PixSz*w(k))^2/(4*thalf{k});
end

DS1=mean(D(1:3));
DS2=mean(D(4:6));
DS3=mean(D(7:9));
D_SEM=SEM_calc([DS1, DS2,DS3]);
D_mean=mean(D);

end

