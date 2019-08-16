%% Quantitative Analysis of Quenched PCB Data
% This code is used to process photocleavable tension data. Analysis is
% performed on a per CELL (not per podosome) basis). The flow is shown in
% SI Figure 22 a. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Bring in Data

% Naming structure:
% CN(C)(M)
% C refers to Cells. 
% N is the bioreplicate. 
% (C) denotes whether the data in the folder is a control. Folders marked with (C) are controls meaning they contained regular, not photocleavable biotin.
% (M) Folders marked "M" in the variable name contain binary masks of photocleaved ROIs. These are be obtained in the Nikon Elements software.
C1='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181002PCB\ContactPCB';
C1C='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181002PCB\ContactControl';
C1CM='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181002PCB\ContactControl_ROIMasks';
C1M='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181002PCB\ContactPCB_ROIMasks';

C2='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\Contact';
C2C='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\ContactControl';
C2M='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\Contact\Masks';
C2CM='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\ContactControl\Masks';

C3='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\CONTACTrep3';
C3C='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181010\ContactControl';
C3M='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181006\CONTACTrep3\Masks';
C3CM='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\CONFOCALDataBackup\181010\ContactControl\Masks';

CM={C1M C2M C3M; C1CM C2CM C3CM}; %Masks
CDat={C1 C2 C3; C1C C2C C3C}; %Data (1st row +PC Biotin, 2nd row Regular Biotin control)
for j=1:2
    for k=1:3
        
        FList{j,k}=FindFiles(CDat{j,k},'*.nd2');
        ROIs{j,k}= FindFiles(CM{j,k},'*.tif');
        for l=1:length(FList{j,k});
            
           RawDat{j,k}{l}= bfopen(FList{j,k}{l}); %load data
           sz=size(RawDat{j,k}{l});
           if isequal(sz,[1 4]) %Make sure data is aquired w same format and saved in same dimensions
            % Restructure data into a usefulform
            for m=1: length(RawDat{j,k}{l}{1,1})
                R= rem(m,3);
                t= round((m+1)/3);
                if R==2
                    Stacks{j,k}{l}{t,2}=RawDat{j,k}{l}{1,1}{m,1}; %Cy3B
                elseif R==0
                    Stacks{j,k}{l}{t,1}=RawDat{j,k}{l}{1,1}{m,1}; %TD
                end
                Stacks{j,k}{l}{t,3}=imread(ROIs{j,k}{l}); %ROI Mask
            end
        end
        end
    end
end

%% Select the cell that was hit by the laser and crop it, get background
close all
for j=1:2
    for k=1:3
        for l=1:length(Stacks{j,k})
            
           close all
            figure('units','normalized','outerposition',[0 0 1 1]);
           
            subplot(1,4,2); imshow(Stacks{j,k}{1,l}{1,2},[0 320]);
           hold on
             B=bwboundaries(Stacks{j,k}{1,l}{1,3});
             plot(B{1}(:,2), B{1}(:,1),'r','LineWidth',1);
           
            subplot(1,4,3); imshow(Stacks{j,k}{1,l}{2,2},[0 320]);
            hold on
            
             plot(B{1}(:,2), B{1}(:,1),'r','LineWidth',1);
            subplot(1,4,4); imshow(Stacks{j,k}{1,l}{2,3},[]);
            hold on
         
             plot(B{1}(:,2), B{1}(:,1),'r','LineWidth',1);
             subplot(1,4,1); imshow(Stacks{j,k}{1,l}{1,1},[]);
              hold on
         
             plot(B{1}(:,2), B{1}(:,1),'r','LineWidth',1);
              hold on
subplot(1,4,1); title('Draw a box around the cell of interest');
            [meanIntensity deviation rectan CellCoords{j,k}{l}]= MeanINoDisp(zeros(size(Stacks{j,k}{1,1}{1,2})));
           
            close all
            
            for t=1:8
            indivcells{j,k}{l}{t,1}= Stacks{j,k}{l}{t,1}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            indivcells{j,k}{l}{t,2}= Stacks{j,k}{l}{t,2}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            indivcells{j,k}{l}{t,3}= Stacks{j,k}{l}{t,3}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            end
            imshow(indivcells{j,k}{l}{1,2},[0 320]);
            hold on
            B=bwboundaries(indivcells{j,k}{l}{1,3}) 
             plot(B{1}(:,2), B{1}(:,1),'r'); %Show photostimulation region
            set(gcf, 'Position', get(0, 'Screensize'));
            title('Draw a box for local background');
            coord=getPosition(imrect);
            ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
            for t=1:8
            Box= double(indivcells{j,k}{l}{t,2}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1): ROIcoords(1,2)));
            MeanI_B{j,k}(l,t)= mean(Box(:)); SDevI_Box{j,k}(l,t)= std(Box(:));
            end
        end
        
    end
end
%% Test for good masking criteria

% You can use this section as needed to test for a masking criteria that
% works well for your imaging. Factors to play with are: # Standard
% deviations above background, the morphological operations, how many
% connected pixels are required, etc. 
%{
for j=1:2
    for k=1:3
        for l=1:length(indivcells{j,k})
            for t=[1 3]
                if t==3
                    T=3; 
                else
                    T=0;
                end
            subplot(2,3,1+T);
            imshow(indivcells{j,k}{l}{t,2},[]);
            subplot(2,3,2+T); 
            imshow(indivcells{j,k}{l}{t,2}>(MeanI_B{j,k}(l,t)+1.25*SDevI_Box{j,k}(l,t)));
            subplot(2,3,3+T);
            imshow(bwmorph(bwareaopen(indivcells{j,k}{l}{t,2}>(MeanI_B{j,k}(l,t)+1.25*SDevI_Box{j,k}(l,t)),30),'majority'));
            end
            waitforbuttonpress
        end
    end
end
%}
%% Mask the Data and perform calculations
close all

    T=[1 3]; % Analysis is performed at the first and third time points. The second time point is immediately after photostim. 1 and 3 are -12 and 29 s, respectively. 
for j=1:2 % Condition
    for k=1:3 % Rep
        
        for l=1:length(indivcells{j,k}) %Image N
          

            % Mask Cells
            IMasks{j,k}{l}=bwmorph(bwareaopen(indivcells{j,k}{l}{1,2}>(MeanI_B{j,k}(l,2)+1.25*SDevI_Box{j,k}(l,2)),30),'majority');
            
            
            % Mask into regions (cleave and not cleaved)
            for t=1:2
                for R=1:2 % ROI: 1 = Cleave ROI ("Proximal"), 2 = Elsewhere ("Distal")
                    if R==1
                        Reg=indivcells{j,k}{l}{1,3};
                    else
                        Reg=~indivcells{j,k}{l}{1,3};
                    end
                    Masked{j,k}{l}{t,R} = double(IMasks{j,k}{l}).*double(indivcells{j,k}{l}{T(t),2}).*double(Reg);
                    Masked{j,k}{l}{t,R}(Masked{j,k}{l}{t,R}==0)=nan;
                    SZ=size(Masked{j,k}{l}{t,R});
                    I_Mean{j,k}{l}(t,R)=mean(Masked{j,k}{l}{t,R}(:),'omitnan');
               
                end
            end
           % waitforbuttonpress
        end
    end
end


%}
%% Unpackage Data, Plot Results, and Perform ANOVA

close all
for t=1:2
    for j=1:2 % PCB or Regular Biotin
        n=1;
        for k=1:3 % Rep Number
            for l=1:length(indivcells{j,k});
                for R=1:2 % Proximal or Distal
                        IPlot{j,R}(n,t)=I_Mean{j,k}{l}(t,R);
                end
                n=n+1;
            end
        end
    end
end

pos=1:8;
sp=1;
POS=[.5 1 2 2.5]
SP=1;
for j=1:2
    for R=1:2
      
        Delta{j,R}=100.*(IPlot{j,R}(:,2)-IPlot{j,R}(:,1))./IPlot{j,R}(:,1);
        MD(j,R)=median(Delta{j,R});
        figure(TT); hold on;
        X=ones(length(Delta{j,R}),1).*POS(SP);
        scatter(X, Delta{j,R},'.b','jitter','on', 'jitterAmount', 0.05);
        hold on
        plot([POS(SP)-.15 POS(SP)+.15],[MD(j,R) MD(j,R)],'-r');
        xlim([0 3]);
        ylim([ -80 20]);
        SP=1+SP;
    end
end

% Perform statistics with an anova
% Prep Data 
    %Column is Region
    % Row is Exp (top) , Control (bottom)
    % N samples = pdlen
    clear Mat2Stat g2 g1
    Mat2Stat=[Delta{1,1};Delta{2,1}; Delta{1,2};Delta{2,2}];
    Loc={'P','D'}; Samp={'Exp','Cont'};
   
    for j=1:23
        g1{j}='P';
        g2{j}='Exp';
    end
    for j=24:49
        g1{j}='D';
        g2{j}='Exp';
    end
    for j=50:72
        g1{j}='P';
        g2{j}='Cont';
    end
    for j=73:98
        g1{j}='D';
        g2{j}='Cont';
    end
    figure(1)
 nmbpods = 172; 
[~,~,stats] = anovan(Mat2Stat,{g1, g2}, 'model','full','varnames',{'ROI','Probe'})
results = multcompare(stats,'Dimension',[1 2])
figure(4);
hold on
for R=1:2
    X=ones(length(Delta{1,R}),1).*R;
        scatter(X, Delta{1,R},'.b','jitter','on', 'jitterAmount', 0.15);
        plot([R-.15 R+.15],[MD(1,R) MD(1,R)]);
end
xlim([0 3]);
ylim([-80 0]);
[pPCBROIs]=ranksum(Delta{1,1}, Delta{1,2});
plot([1 2],[-16 -16],'-k');
text(1.5, -17, SigStars(pPCBROIs),'FontName','Arial','FontSize',14);

%% Normalize Data


% Normalize Data
for j=1:2 
    for k=1:3
        
        for c=1:length(indivcells{j,k})
            for t=1:8
                 % In the paper we did not convert to double precision before
           % normalization, but we recommend doing this and running this section of code before normalization
           % for higher quality figures.
           %{
                for J=1:3
                indivcells{j,k}{1,c}{t,J}=double(indivcells{j,k}{1,c}{t,J});
                end
           %}
                indivcells{j,k}{1,c}{t,4}=indivcells{j,k}{c}{1,2}./MeanI_B{j,k}(c,t);
                
            end
        end
    end
end
%% Generate Fig Ims w ROIs drawn

% This code can be used to plot data.
% j = condition , k = biorep, C = Image number
j=1; k=2; C=8; len = 85 % (Length of Image - 1)/2
      close all
     
     
      figure(1); imshow(indivcells{j,k}{C}{1,1},[]);
    [cppe rppe]=ginput(1); rppe=round(rppe); cppe= round(cppe);
     coord=[rppe-len rppe+len; cppe-len cppe+len];
     
    imshow(indivcells{j,k}{C}{1,4}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),[]);
       [r c]=ginput();
     c=round(c); r=round(r);
     c_=c-9; C_=c+10; r_=r-9; R_=r+10;
     ROIm=zeros(size(indivcells{j,k}{C}{1,1}(coord(1,1):coord(1,2), coord(2,1): coord(2,2))));
     ROIm(c_:C_, r_:R_)=1;
  
     figure(4);
     
       for t=1:8
          
    for ch=1:4
PP_E{t,ch}= indivcells{j,k}{C}{t,ch}(coord(1,1):coord(1,2), coord(2,1): coord(2,2));
    end
          
       end
       BBB2= bwboundaries(ROIm);
       for t=1:3
       subplot(2,2,t);
     imshow(PP_E{t,4}(c_:C_, r_:R_), [0 6.5]);
       end
      
       figure(15);
       
       Corn= corner(indivcells{j,k}{C}{1,3}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)))
       for t=1:3
       subplot(2,2,t);
     imshow(PP_E{t,4}(Corn(1,2):Corn(2,2),Corn(1,1):Corn(3,1)), [0  6.5]);
       end
       figure(12);
       
     BBB= bwboundaries(indivcells{j,k}{C}{1,3}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)))
    subplot(2,2,1);
     imshow(indivcells{j,k}{C}{1,1}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)), [20 350]);
     hold on
     plot(BBB{1}(:,2), BBB{1}(:,1),'r');  plot(BBB2{1}(:,2), BBB2{1}(:,1),'b');
     ScaleBar(indivcells{j,k}{C}{1,1}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),.14,5)
    
   
   subplot(2,2,2); imshow(indivcells{j,k}{C}{1,4}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),[0 6.5]); 
    hold on
   plot(BBB{1}(:,2), BBB{1}(:,1),'r');  plot(BBB2{1}(:,2), BBB2{1}(:,1),'b');%Show photostimulation region
    subplot(2,2,3); imshow(indivcells{j,k}{C}{2,4}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),[0  6.5]); 
    hold on
    plot(BBB{1}(:,2), BBB{1}(:,1),'r');  plot(BBB2{1}(:,2), BBB2{1}(:,1),'b');%Show photostimulation region
    subplot(2,2,4); imshow(indivcells{j,k}{C}{3,4}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),[0  6.5]); 
    hold on
     plot(BBB{1}(:,2), BBB{1}(:,1),'r');  plot(BBB2{1}(:,2), BBB2{1}(:,1),'b'); %Show photostimulation region
     
     %}
     figure(11);
     for t=1:3
     subplot(1,3,t)
     imshow(indivcells{j,k}{C}{t,1}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),[20 350])
     ScaleBar(indivcells{j,k}{C}{t,1}(coord(1,1):coord(1,2), coord(2,1): coord(2,2)),.14,5)
     end

