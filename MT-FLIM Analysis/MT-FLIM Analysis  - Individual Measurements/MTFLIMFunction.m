function [CellVars] = MTFLIMFunction(ImageAdd, LUT, IllumProf, Cond, LifeMax, COFF)
% This function will create a PodImage2 for your MTFLIM Images.
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
close all

% Input: 
%   ImageAdd = Image Address
%   LUT = CustomLUT - The lookup table with MTFLIM callibration
%   IllumProf = Illumination Profile for the imaging settings used in your
%   expeiments
%   Cond = Condition ('Four','Nineteen', or 'Lin')
%   LifeMax = Cutoff lifetime defined as 1 SD (IN VARIANCE, not based on
%   centers) of 100% open probes.
%   COFF = Cutoff photon counts (25)

    % Import raw Picoquant data which is stored as a .tif with 
    % Ch 1 = Photon Counts and Ch 2 = FASTFLIM Av Lifetime 
    [Cts_PreCorr AvLife]=ImportPQTif(ImageAdd);
    
    % Correct for illumination profile
    Cts= Cts_PreCorr./IllumProf;
    
    % Calculate percent open
    
    if strcmp(Cond, 'Lin')==0
    Percent=PercentO(AvLife, LUT); 
    else
        Percent = zeros(512);
    end
    
    % Make a mask of pixels that are not considered in analysis
    NANMask=ones(512);
    NANMask(Cts_PreCorr<COFF)=nan;
    NANMask(AvLife>LifeMax)=nan;
    
    CtsNAN=NANMask.*Cts; AvLifeNAN= AvLife.*NANMask;
    
    % Create an Object
    PI=PodImage2;
    PI.Condition=Cond;
    PI.FileAddress=ImageAdd;
    PI.Counts=Cts; PI.AvLife=AvLife; PI.Percent=Percent; 
    PI.Cts_PreCorr=Cts_PreCorr;
    PI.Percent = Percent;
    
    
    % Count number of cells with podosomes in the image
    figure(2); 
    imshow(Cts,[0 350]);
    set(gcf, 'Position' ,get(0,'Screensize'));
    saveto = {'# Podosome-Forming Cells to Analyze'};
    dlg_title = 'Cell Ct';
    num_lines = 1;
    CellCt = inputdlg(saveto,dlg_title,num_lines);
    CellNumber=str2double(CellCt{1});  
    CellSpots=cell(CellNumber,1);
    CtsMask=cell(CellNumber,1);
    Cts_B=[]; Cts_B_SDev=[]; Rectan=[]; AvLifeB=[];MeanPodDensity=[];
    
    % Perform masking and get statistics for every cell
    
    for j=1:CellNumber
        figure(2); imshow(Cts,[]);
        title('Pick Background');
        [Cts_B(j) Cts_B_SDev(j) Rectan{j} ROIcoords1{j}]= MeanINoDisp(CtsNAN);
        BSpot = AvLifeNAN(ROIcoords1{j}(2,1):ROIcoords1{j}(2,2), ROIcoords1{j}(1,1):ROIcoords1{j}(1,2));
        AvLifeB(j)= mean(BSpot(:),'omitnan');
        Density{j}= Clustering(CtsNAN, Cts_B(j), Percent);
        PI.ClusterIm = Density{j};
        title('Pick Cell');
        H= imrect();
        coord=round(H.getPosition);
        ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
        CellSpots{j}=zeros(512);
        CellSpots{j}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2))=1;
        se=strel('diamond',1);
        % Create initial podosome mask
        PodSpots=Cts<(Cts_B(j)-3.5*Cts_B_SDev(j));
        % Remove small objects
        PodMask{j}=bwareaopen(imclose(PodSpots.*CellSpots{j},se),6);
        figure(8);
        set(gcf, 'Position', get(0, 'Screensize'));
        subplot(1,3,1); imshow(Cts,[]); subplot(1,3,2); imshow(AvLife,[1 2.5].*10^-9); colormap(gca, parula); subplot(1,3,3); imshow(PodMask{j}); 
    
        % Check for surface defects like holes that got picked up by filter
        % or regions that were poorly thresholded and you can obvioiusly
        % tell are not podosomes. Mask them out manually. 
        
        saveto2 = {'Surface Defect Detect'};
        dlg_title = 'Are there defects (poor masking or SLB hole) that need to be removed? How Many (0 or integer)?';
        num_lines = 1;
        D = inputdlg(saveto2,dlg_title,num_lines);
        Defect=str2double(D{1});  
        if Defect ~=0
            for d=1:Defect
               subplot(1,2,1); imshow(Cts,[]); subplot(1,2,2); imshow(PodMask{j});set(gcf, 'Position', get(0, 'Screensize'));
                HH=imrect(); cH=round(HH.getPosition); RC{d}=round([cH(1) cH(1)+cH(3); cH(2) cH(2)+cH(4)]); 
                PodMask{j}(RC{d}(2,1): RC{d}(2,2), RC{d}(1,1): RC{d}(1,2))=0;
            end
            close;
            imshow(PodMask{j});
        else
        end
    
        % Proceed with masking and calculations
        
        PodMask{j}=double(PodMask{j}); CellSpots{j}=double(CellSpots{j});
        se1= strel('diamond',3);
        PodRegions{j}=imdilate(PodMask{j},se1);
        PodRegionsStamped{j}=PodRegions{j}.*NANMask;
        figure(9); imshow(PodRegionsStamped{j});
       
        
        ToQuantify= {PodRegionsStamped{j}.*AvLife, PodRegionsStamped{j}.*Percent, PodRegionsStamped{j}.*PI.ClusterIm};
            for jj=1:3
                ToQuantify{jj}(ToQuantify{jj}==0)=nan;
            end
            PI.MeanPercent=mean(ToQuantify{2}(:),'omitnan');
            PI.PodAvs=mean(ToQuantify{1}(:),'omitnan');
            PI.MeanDensity=mean(ToQuantify{3}(:),'omitnan');
            PI.BAv_Cts= Cts_B(j);
            PI.BAv_Life= AvLifeB(j)
            PI.CtsCutoff = COFF
            PI.BDevs = Cts_B_SDev(j)
            PI.Mask=PodRegions{j};
            PI.CellRegion = CellSpots{j}
            PI.NANMask=NANMask; 
            PI.CountsNAN= CtsNAN;
            PI.AvLifeNAN= AvLifeNAN;
            CellVars{j}=PI;
            close all
    end
    
    close all
    
    
    end

