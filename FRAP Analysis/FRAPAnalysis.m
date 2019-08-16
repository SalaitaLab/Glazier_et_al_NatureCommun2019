%% This script can be used to determine the diffusion coefficient of your SLB
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
% This function assumes that photobleaching is negligable in your
% time-lapse, but you must confirm these effects for your data. 


% Store your 3 replicates each w 3 FRAPs replicates labeled accordingly as
% individual ND2 files in 2 folders. The Pre folder contains images
% collected before photobleaching. The post folder contains timelapse data
% collected every 30 s for 180 s following bleaching. 

clear all
FileAddress='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\ContactProbe_Clustering\180420\FRAP';
Folders={'Pre','Stacks'};
[D_mean D_SEM D1 D2 D3]= SLBFRAP(FileAddress, Folders, 0.16);


