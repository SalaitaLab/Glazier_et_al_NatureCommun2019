%% This script can be used to process your MT-FLIM data and comparing the results of the same cells before and after pharmacological inhibition. 
% We include a sample image for Jasplakinolide. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Load and define important variables
clear 

load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FLIMIlluminationData.mat', 'IllumProfz5');
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FixedCalVars.mat','CustomLUT');
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PodosomeAnalysis\1801cutoffcorrection\CutoffVars190127.mat', 'Life100max_1sd');

LUT= CustomLUT{1,2}; 
IllumProf = IllumProfz5;
LifeMax = Life100max_1sd;

%% Load in drug data and run per cell analysis

% Input the file address that holds your drug data (2 subfolders w before
% and after data)
FNa='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\Jasplak';
Cond='Jasplak_Pre',CondPost='Jasplak_Post'; 
Drug = 'Jasplakinolide';
FN= fullfile(FNa, Cond);
FileList=FindFiles(FN,'*.tif');
FNPost=fullfile(FNa,CondPost);
FileListPost=FindFiles(FNPost, '*.tif');

JasplakVars={};
for j=1:5 % length(FileList)
    CVars=MTFLIM_DrugAnalysisFunction(FileList{j}, FileListPost{j}, IllumProf, LUT, LifeMax, Drug);
    DummyMat= {JasplakVars, CVars};
   	JasplakVars=cat(2,DummyMat{:});
end

%% Plot Change in Percent Open Probes
% We suggest performing pairwise (by cell) statistics in GraphPad Prism. 
[MeanPercent, MeanLine_Perc, MedLine_Perc] = PercentOpenProc_Drug(JasplakVars);
DrugScatter(MeanPercent', MeanLine_Perc, 35)

%% Plot Average Radius
% Statistics were calculated in GraphPad 7
% To be included, podosomes must be picked up by
% thresholding processing above and be larger than the minimum pixel
% requirement in the thresholding. Furthermore, it must be relatively circular to meet the
% eccentricity requirement. Thus, you will want to analyze many cells to observe a population trend.
PlotRadius(Radii, MeanLine); 
[Radii, MedLine, MeanLine]= RadiusProc(JasplakVars, 0.14);



