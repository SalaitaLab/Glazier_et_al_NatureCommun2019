function [CellData25] = MTFLIM_DrugAnalysisFunction(PreIm, PostIm, IllumProf,LUT, LifeMax, Drug)
%This MTFLIM function is used to analyze before and after drug images on
%teh same regions of the SLB.
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
% Load data
[Pre_PreCorr Pre_AvLife] = ImportPQTif(PreIm);
[Post_PreCorr Post_AvLife]= ImportPQTif(PostIm);
Adds={PreIm, PostIm};
% Find Cells
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(1,2,1); imshow(Pre_PreCorr,[50 300]); subplot(1,2,2); imshow(Post_PreCorr,[50 300]);
saveto = {'# Cells w Podosomes to Analyze'};
dlg_title = 'Cell Ct';
num_lines = 1;
CellCt = inputdlg(saveto,dlg_title,num_lines);
CellNumber=str2double(CellCt{1});
CellSpots=cell(CellNumber,1);
CtsMask=cell(CellNumber,1);
CellData25={};
ct=1;
for jj=1:CellNumber
   
    for k=1:2
        subplot(1,2,1); imshow(Pre_PreCorr,[50 300]); subplot(1,2,2); imshow(Post_PreCorr,[50 300]);
        
        
        if k==1
        suptitle('Draw box on left (before) panel to analyze');
        subplot(1,2,k); imshow(Pre_PreCorr,[50 300]);
        else 
            suptitle('Draw corresponding box on right (after) panel to analyze');
            subplot(1,2,2); imshow(Post_PreCorr,[50 300]);
        end
        
     coord=getPosition(imrect);
     ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
     CellSpots=zeros(512);
    CellSpots(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2))=1;
     
    CellData25{k,ct}=PodImage2;
    CellData25{k,ct}.CellRegion=CellSpots;
    CellData25{k,ct}.FileAddress=Adds{k};
    end
    ct=ct+1;
end
close all

for t=1:2
    for c=1:size(CellData25,2)
        [Cts_PreCorr AvLife]=ImportPQTif(CellData25{t,c}.FileAddress);
        Cts=Cts_PreCorr./IllumProf; 
        
        % Cutoff Masking
        NANMask=ones(512);
        NANMask(Cts_PreCorr<25)=nan;
        NANMask(AvLife>LifeMax)=nan;
        CtsNAN=Cts.*NANMask; AvLifeNAN=AvLife.*NANMask;
        
        CellData25{t,c}.Counts=Cts;
        CellData25{t,c}.CountsNAN=CtsNAN;
        CellData25{t,c}.AvLife=AvLife;
        CellData25{t,c}.AvLifeNAN=AvLifeNAN;
        CellData25{t,c}.Condition=Drug;
        CellData25{t,c}.Cts_PreCorr=Cts_PreCorr;
        CellData25{t,c}.NANMask=NANMask;
        
        % Find Local Background
        figure(1); imshow(Cts,[0 300]);
        B=bwboundaries(CellData25{t,c}.CellRegion);
        hold on;
        plot(B{1}(:,2), B{1}(:,1),'r');
        title('Draw a box around local background in a relatively defect free region');
        coord= getPosition(imrect);
        ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
        CB=CtsNAN(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));
        ALB=AvLifeNAN(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));

        CellData25{t,c}.BAv_Cts=mean(CB(:),'omitnan');
        CellData25{t,c}.BAv_Life=mean(ALB(:),'omitnan');
        CellData25{t,c}.BDevs=std(CB(:),'omitnan');
        
        % Caculate percent open
        % Note: We used the same callibration for images collected with zoom3 and zoom5 since no significant difference was found. For more information, see Supplementary Note 1.  
        Percent= PercentO(CellData25{t,c}.AvLife,LUT); 
        CellData25{t,c}.Percent=Percent;
   c
    end
end
close all

for t=1:2 
    Sz= size(CellData25);
    for c=1:size(CellData25,2)
        se=strel('diamond',1);
        % Find Podosome regions
         PodSpots=CellData25{t,c}.Counts<(CellData25{t,c}.BAv_Cts-(3.25*CellData25{t,c}.BDevs));
         PodMask=bwareaopen(imclose(PodSpots.*CellData25{t,c}.CellRegion,se),6);
        figure(4); imshow(PodMask);
        figure(8); set(gcf,'Position', get(0,'Screensize'));
        
        % Correct poorly masked regions
        subplot(1,3,1); imshow(CellData25{t,c}.Counts,[0 300]);
        subplot(1,3,2); imshow(CellData25{t,c}.AvLife,[1 2.5].*10^-9); colormap(gca, parula);
        subplot(1,3,3); imshow(PodMask);
         
        saveto={'Surface Defect Detect'};
        dlg_title= 'Are there any poorly masked regions or surface defects? (0 or integer)';
        num_lines = 1
        D = inputdlg(saveto, dlg_title, num_lines);
        Defect= str2double(D{1});
        
        if Defect ~=0
            for d=1:Defect
                subplot(1,2,1); imshow(CellData25{t,c}.Counts,[0 300]);
                subplot(1,2,2); imshow(PodMask); set(gcf, 'Position', get(0,'Screensize'));
                title('Draw small boxes around any defect regions')
                HH= imrect(); cH=round(HH.getPosition); RC{d}=round([cH(1) cH(1)+cH(3); cH(2) cH(2)+cH(4)]); 
                PodMask(RC{d}(2,1): RC{d}(2,2), RC{d}(1,1): RC{d}(1,2))=0;
            end
            close;
            imshow(PodMask);
           
        end
        CellData25{t,c}.Mask = PodMask;
        P=regionprops('table',logical(CellData25{t,c}.Mask), 'Centroid','MajorAxisLength','MinorAxisLength','Eccentricity','Area'); 
        CellData25{t,c}.Props = P
        close
    end
end

    % Complete masking and perform calculations
    
    for t=1:2
        for c=1:size(CellData25,2)
            CellData25{t,c}.Mask= double(CellData25{t,c}.Mask);
            se1=strel('diamond',3);
            PodRegions = imdilate(CellData25{t,c}.Mask,se1);
            PodRegionsStamped= PodRegions.*~isnan(CellData25{t,c}.CountsNAN);
            ToQuantify = {PodRegionsStamped.*CellData25{t,c}.AvLife, PodRegionsStamped.*CellData25{t,c}.Percent};
            for jj=1:2
                ToQuantify{jj}(ToQuantify{jj}==0)=nan;
            end
            CellData25{t,c}.MeanPercent=mean(ToQuantify{2}(:),'omitnan');
            CellData25{t,c}.PodAvs=mean(ToQuantify{1}(:),'omitnan');
        end
    end
   
    close all;
    
    
    
    
    
    end






