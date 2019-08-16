%% Process MT-FLIM data on a PER IMAGE (not per cell) basis to feed into photon analysis
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
% Run these two sections for each of your conditions. They are separated
% into two sections to prevent mistakes. You MUST change the variable where
% these objects are stored so they ar matched to the right place (4.7, 19,
% or Linear variable). These spots that need to be changed are indicated. 

% The general process of performing this analysis is to 1) Load images 2)
% Select 3 background regions per image 3) If there are any regions that
% were picked up as podosomes but are clearly not, remove them manually
% from mask w a box, and 3) Perform calculations to save maks on an image
% basis. 

% The results from this analysis are used to determine the cutoff
% variables. 

%% Address and Load Variables
close all
clc

% Load illlumination and callibration variables (made w MTFLIMCal and
% FLIM_IllumCalcs).
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FLIMIlluminationData.mat','IllumProfz3', 'IllumProfz5');
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FixedCalVars.mat','CustomLUT');

% Load Images
FNa='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips';
Cond='Lin', FNc='LinCells2Analyze'; 

% Set up variables - Make sure you are using the correct
% Illumination profile for your images (I used z5 for F2 and z3 for other
% MTFLIM images) and the correct CustomLUT for your data (4.7 vs 19). For
% Linear data, all percents are set to 0, so it doesn't really matter. 
FN= fullfile(FNa, Cond, FNc); P=CustomLUT{2,2}; IllumProf=IllumProfz5;
FileList=FindFiles(FN,'*.tif'); COFF=0 %Sets photon count cutoff
%% Process Images. STOP. FIRST MAKE SURE YOUR ANALYSIS WILL BE SAVED TO THE RIGHT VARIABLE. 

% For linear images: Ims_L
% For 4.7 pN images: Ims_F
% For 19 pN images: Ims_N

% You must make this change at the three sites indicated in the code below:
% Line 35,36 and Line 130

clc; close all;
clearvars -except Ims_N Ims_F Ims_L Four_0 N_0 N1_0 N2_0 Nineteen_0 F_0 F1_0 F2_0 F3_0 L_0 Linear_0 L1_0 L2_0 L_50 L2_50 L_50 L1_50 N1_50 N2_50 N_50 Four_50ct F1_50 F2_50 F3_50 F_50 Test COFF J ffactor FileList Lin1 Lin2 Lin Cond CustomLUT Four Four1 Four2 Four3 FourPods Nineteen1 Nineteen Nineteen2 NineteenTot LinPods IllumProf P
% Change to Ims_L/F/N
Ims_L=[];
cct=length(Ims_L)+1;

for J=1:length(FileList) %Loop through all cell ims
    [Cts_PreCorr AvLife]=ImportPQTif(FileList{J,1});
    Cts=Cts_PreCorr./IllumProf; %Correct for uneven illumination
    
    if strcmp(Cond, 'Lin')==0
    Percent=PercentO(AvLife, P); %Calculate percent open im w LUT
    else
    Percent=zeros(512);
    end
    
    %Create an Object
    PI=PodImage2;
    PI.Condition=Cond;
    PI.FileAddress=FileList{J};
    PI.Counts=Cts; PI.AvLife=AvLife; PI.Percent=Percent; 
    PI.Cts_PreCorr=Cts_PreCorr;
    
    %Count Number of Cells in Image
    figure(2); 
    imshow(Cts,[0 350]); 
    for j=1:3
    Cts_B=[]; Cts_B_SDev=[]; Rectan=[]; AvLifeB=[];MeanPodDensity=[];
    title('Select 3 background Regions  and hit enter');
    [Cts_B Cts_B_SDev Rectan ROIcoords1]=MeanINoDisp(Cts);
    BSpot{j}=AvLife(ROIcoords1(2,1):ROIcoords1(2,2), ROIcoords1(1,1):ROIcoords1(1,2)); %allows to omit pix below cutoff from calc without changing saved variable
    CSpot{j}=Cts(ROIcoords1(2,1):ROIcoords1(2,2), ROIcoords1(1,1):ROIcoords1(1,2));
    B{j}=BSpot{j}(:); C{j}=CSpot{j}(:);
    end
    BackLife=[B{1}; B{2}; B{3}];
    BackCts=[C{1}; C{2} ;C{3}];
    Cts_B=mean(BackCts(:),'omitnan');
    Cts_B_SDev=std(BackCts(:),'omitnan');
    AvLifeB=mean(BackLife(:),'omitnan');
    Density=Clustering(Cts, Cts_B, Percent); %Calculate density using counts, background, and percent
    PodSpots=Cts<(Cts_B-3.5*Cts_B_SDev);
    se=strel('diamond',1);
    PodMask=bwareaopen(imclose(PodSpots,se),6);
    figure(8);
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(1,3,1); imshow(Cts,[]); 
    subplot(1,3,2); imshow(AvLife,[1 2.5].*10^-9); colormap(gca, parula);
    subplot(1,3,3); imshow(PodMask); 
    
    % Are there surface defects analyzed?
    saveto = {'Surface Defect Detect'};
    dlg_title = 'Are there defects? How Many (0 or integer)?';
    num_lines = 1;
    D = inputdlg(saveto,dlg_title,num_lines);
    Defect=str2double(D{1});  
    if Defect ~=0
        for d=1:Defect
           subplot(1,2,1); imshow(Cts,[]); subplot(1,2,2); 
           suptitle('Draw boxes around any sections that are defects/ bad masking and they will be set to 0');
           imshow(PodMask);
           % set(gcf, 'Position', get(0, 'Screensize'));
            HH=imrect(); cH=round(HH.getPosition); RC{d}=round([cH(1) cH(1)+cH(3); cH(2) cH(2)+cH(4)]); 
            PodMask(RC{d}(2,1): RC{d}(2,2), RC{d}(1,1): RC{d}(1,2))=0;
        end
        close;
        imshow(PodMask); title('Corrected Mask');
    else
        close
    end
    
    % Do calculations and Masking
    PodMask=double(PodMask); 
    PodProps=regionprops('table',logical(PodMask), 'Centroid','MajorAxisLength','MinorAxisLength','Eccentricity','Area'); 
    se1=strel('diamond',3);
    PodRegions=imdilate(PodMask,se1);
    PodRegionsStamped=PodRegions.*~(Cts_PreCorr<=COFF);
    ToProcess=PodRegionsStamped.*AvLife;
    
    ToProcess=double(ToProcess);
    ToProcess(PodRegions==0)=NaN;
   
    DensityAtPods=~PodMask.*PodRegions.*Density;
    DensityAtPods=double(DensityAtPods);
    DensityAtPods(DensityAtPods==0)=NaN;
    MeanPodDensity=mean(DensityAtPods(:),'omitnan');
    M=mean(ToProcess(:),'omitnan');
  
    PercentMap=Percent.*PodRegionsStamped;
    PercentMap=double(PercentMap);
    PercentMap(PodRegionsStamped==0)=NaN;

   MP(j)=mean(PercentMap(:),'omitnan');
  
    imshow(Cts,[]); 
     set(gcf, 'Position', get(0, 'Screensize'));
   PI.ClusterIm=Density;
   
    PI.MeanDensity=MeanPodDensity;
    PI.BAv_Cts=Cts_B;
    PI.BAv_Life=AvLifeB;
    PI.Mask=PodRegions;
    PI.PodAvs=M; PI.MeanPercent=MP;
    PI.DeltaPodAvs=M-AvLifeB;
    PI.CtsCutoff=COFF;
    PI.BDevs=Cts_B_SDev;
    % Change to Ims_L/Ims_F/Ims_N
    Ims_L{cct}=PI;
    cct=cct+1;
end
close

    
%}

