function [RawData, MeanMatrix, DevMatrix, LookAt] = PercOpen_Intensity(FileAddress)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is FileAddress for all data of a condition. 
%   1) Load Data
%   2) Background Subtract
%   3) Mean Intensity
LookAt=[];
  MeanMatrix=[];
DataList=FindFiles(FileAddress, '*.nd2')
ISLB=[]
DevMatrix=[];
for j=1:length(DataList)
   
    RawData{j}=bfopen(DataList{j});
    if j==3 % missing file
    if strcmp(FileAddress, 'C:\Users\roxgl\OneDrive\Desktop\Salaita Lab\Data\TensionProbeCalData\Four')
        RawData{1,j}{1,1}{10,1}=zeros(512).*NaN;
    end
    end
    for k=1:length(RawData{1,j}{1,1})
         BSData{j,k}=RawData{1,j}{1,1}{k,1}(200:400, 200:400)-200;
         B=double(BSData{j,k}); 
  
         bmean=mean(B(:),'omitnan');
         bstd=std(B(:),'omitnan');
         B(B<=(-2*bstd+bmean))=NaN;
         B(B>=(2*bstd+bmean))=NaN;
         
         ISLB(k)=mean(B(:),'omitnan');
         
        LookAt{j,k}=mean(B(:),'omitnan');
        if isempty(ISLB(k))
            ISLB(k)=NaN;
        end
    end
   
    MeanMatrix(j)=mean(ISLB,'omitnan');
    DevMatrix(j)=std(ISLB,'omitnan');
  
end
  
end


