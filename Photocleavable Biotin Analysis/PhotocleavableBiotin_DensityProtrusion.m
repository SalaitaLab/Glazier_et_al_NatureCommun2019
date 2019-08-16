% This is used to process percent change in podosome radius in
% photocleavable biotin experiments. The general strategy is illustrated in
% SI 22 b. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Bring in the data
% 
% PCB has PCB 4.7-TTT, Cy3B Lig, A21 no B. Control has a regular 4.7-TTT,
% hairpin, Cy3B Lig, and A21B as an anchor strand.

% Images and Masks are stored in an overarching folder, respectively, with folders containing
% replicates, as follows. 
P='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PCB\180806_PCB\SeparateOut15percentLaserDat';
ROI='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PCB\180806_PCB\SeparateOut15percentLaserDat\ROIMask_15PercentLaser';
FolderNames={'PCB1','PCB2','PCB3'; 'Control1','Control2','Control3'};
for j=1:2 %condition
    for k=1:3 %bioreplicate
        
        PCBFiles{j,k}= FindFiles(fullfile(P,FolderNames{j,k}),'*.nd2');
        ROIs{j,k}= FindFiles(fullfile(ROI, FolderNames{j,k}),'*.tif');
        for l=1:length(PCBFiles{j,k});
            
           RawDat{j,k}{l}= bfopen(PCBFiles{j,k}{l}); %load data
           sz=size(RawDat{j,k}{l});
           if isequal(sz,[1 4]) %Make sure data is aquired w same format and saved in same dimensions as sometimes Nikon stores the data in a strange format.
            % Restructure data into a usefulform
            for m=1: length(RawDat{j,k}{l}{1,1})
                R= rem(m,3);
                t= round((m+1)/3);
                if R==2
                    Stacks{j,k}{l}{t,2}=RawDat{j,k}{l}{1,1}{m,1}; %Cy3B
                elseif R==0
                    Stacks{j,k}{l}{t,1}=RawDat{j,k}{l}{1,1}{m,1}; %TD
                end
                Stacks{j,k}{l}{t,3}=imread(ROIs{j,k}{l});
            end
        end
        end
    end
end

%% Select the cell that was hit by the laser and crop it, get background, 

for j=2
    for k=1:3
        for l=1:length(Stacks{j,k})
            
           
            figure('units','normalized','outerposition',[0 0 1 1]);
           
            subplot(1,4,2); imshow(Stacks{j,k}{1,l}{1,2},[0 1200]);
            subplot(1,4,3); imshow(Stacks{j,k}{1,l}{2,2},[0 1200]);
            subplot(1,4,4); imshow(Stacks{j,k}{1,l}{2,3},[]);
             subplot(1,4,1); imshow(Stacks{j,k}{1,l}{1,1},[]);
            title('Based on ROI Mask in Subplot 4, Select Cell Region that was photostimulated');
            
            
            [meanIntensity deviation rectan CellCoords{j,k}{l}]= MeanINoDisp(zeros(512));
           
            close all
            
            for t=1:8
            indivcells{j,k}{l}{t,1}= Stacks{j,k}{l}{t,1}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            indivcells{j,k}{l}{t,2}= Stacks{j,k}{l}{t,2}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            indivcells{j,k}{l}{t,3}= Stacks{j,k}{l}{t,3}(CellCoords{j,k}{l}(2,1):CellCoords{j,k}{l}(2,2), CellCoords{j,k}{l}(1,1):CellCoords{j,k}{l}(1,2));
            end
            imshow(indivcells{j,k}{l}{1,2},[0 1200]);
            hold on
            B=bwboundaries(indivcells{j,k}{l}{1,3}) 
             plot(B{1}(:,2), B{1}(:,1),'r'); %Show photostimulation region
            set(gcf, 'Position', get(0, 'Screensize'));
            title('Select a local background');
            coord=getPosition(imrect);
            ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
            for t=1:8
            Box= double(indivcells{j,k}{l}{t,2}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1): ROIcoords(1,2)));
            MeanI_B{j,k}(l,t)= mean(Box(:)); SDevI_Box{j,k}(l,t)= std(Box(:));
            end
        end
        
    end
end

%% Find center of Photocleavage ROI

for j=1:2
    for k=1:3
        close
        for l=1:length(indivcells{j,k})
        stats = regionprops('table',indivcells{j,k}{l}{1,3},'Centroid');
        ROcenter{j,k}{l,1} = stats.Centroid;
    %    imshow(indivcells{j,k}{l}{1,3}); hold on; plot(ROcenter{j,k}(1), ROcenter{j,k}(2),'r.');
   % pause(1);
        end
    end
end
%% Draw Cell Region

% To make sure that no defects are processed outside of the cell, we will
% define the cell region here. 
close all
figure('units','normalized','outerposition',[0 0 1 1]);
for j=1:2
    for k=1:3
        for l=1:length(indivcells{j,k});
            imshow(indivcells{j,k}{1,l}{1,1},[]);
            title('Drag an elipse over the cell boundaries');
            h = imellipse;
            CellMask{j,k}{l}=createMask(h);
        end
    end
end
%% Perform masking to identify podosomes before and after photocleavage

for j=1:2 % Condition (PCB or Control)
    for k=1:3 % Replicate
        for l=1 %1:length(indivcells{j,k})
            close all
            BB=bwboundaries(indivcells{j,k}{l}{1,3});
            B{j,k}{l}=BB;
            % I used a gaussian filter to find the background to
            % smooth any noise. This line is not necessary. 
            TrialRun{j,k}{1,l}=imgaussfilt(indivcells{j,k}{1,l}{1,2});
            imshow(TrialRun{j,k}{1,l},[]);  set(gcf, 'Position', get(0, 'Screensize'));hold on;
            plot(B{j,k}{1,l}{1,1}(:,2), B{j,k}{1,l}{1,1}(:,1),'r');
     
         [mi md rect broic]=MeanINoDisp(double(TrialRun{j,k}{1,l}));
            for zz=[1 3] % zz = time, 1 = -12 seconds (pre photocleavage), 3 = 29 s (post photocleavage)
                close all
               rectan=double(indivcells{j,k}{1,l}{zz,2}(broic(2,1):broic(2,2), broic(1,1):broic(1,2)));
               MI{j,k}{1,l}(zz)= mean(rectan(:),'omitnan');
                MD{j,k}{1,l}(zz)= std(rectan(:),'omitnan');
                
                % I found that I needed to use a slightly different threshold
                % in biorep 3. These parameters will need to be tuned for
                % your data. 
             if ismember(k,[1 2]);
                 NNN=3;
             else
                 NNN=4;
             end
             % Threshold and remove objects smaller than 4 pix, multiply by
             % Cell Mask to clear background junk.
                MaskTrialRun{j,k}{zz,l}=(bwareaopen(indivcells{j,k}{1,l}{zz,2}<(MI{j,k}{1,l}(1,zz)-NNN*MD{j,k}{1,l}(1,zz)),4)).*CellMask{j,k}{l};
             subplot(2,2,1); imshow(indivcells{j,k}{1,l}{1,2},[]); hold on;
            subplot(2,2,2); imshow(MaskTrialRun{j,k}{1,l});hold on; title('-12 s');
            subplot(2,2,3); imshow(indivcells{j,k}{1,l}{3,2},[]);hold on;
            subplot(2,2,4); imshow(MaskTrialRun{j,k}{3,l});hold on; title('29 s');
            
            for p=1:4
               
                subplot(2,2,p); 
                plot(B{j,k}{1,l}{1,1}(:,2), B{j,k}{1,l}{1,1}(:,1),'r');
            end
            suptitle('Click to move on');
            
        end
     waitforbuttonpress
            
            
            end
        end
    end

%}
%% Overlap masks and only accept connected regions that belong to both time points 

for j=1:2
    for k=1:3
        for l=1:length(indivcells{j,k})
              Overlap{j,k}{l}=MaskTrialRun{j,k}{1,l}.*MaskTrialRun{j,k}{3,l};
                for m=1:2
                if m==1
                 MaskMat{m}{j,k}{l}=MaskTrialRun{j,k}{1,l};
                FinalMaskMat{m}{j,k}{l}=MaskTrialRun{j,k}{1,l};
                else
                    MaskMat{m}{j,k}{l}=MaskTrialRun{j,k}{3,l};
                      FinalMaskMat{m}{j,k}{l}=MaskTrialRun{j,k}{3,l};
                end
                LabMask=[];
                LabMask=bwlabel(MaskMat{1,m}{j,k}{l});
                for n=1:max(LabMask(:))
                    belong=(LabMask==n).*Overlap{j,k}{l};
                    if max(belong(:))==0
                        FinalMaskMat{1,m}{j,k}{l}(LabMask==n)=0;
                    end
                end
                
                 subplot(1,2,m); imshow(FinalMaskMat{m}{j,k}{l}); 
                 hold on
               plot(B{j,k}{1,l}{1,1}(:,2), B{j,k}{1,l}{1,1}(:,1),'r');
                end
                title(strcat(num2str(j),  num2str(k) ,num2str(l)));
        end
    end
end


%

%%  Separate podosomes using 2-pixel-wide lines 
%{
% This section is critical to the processing of this data. In this data set
% we have: 
Biological Challenges:
Podosomes split, merge, move
Podosomes do not have one size 
Thresholding Challenges:
Podosomes are not always distinguishable from their neighbors
Thresholding does not always provide clear maps of podosome-specific depletion
Podosomes are small and can get lost in the noise
%} 

% With this "intervention" step, we can recover similar podosomes for
% analysis. 

% We recommend running this section twice to check that you didn't miss any
% 'doublets'

% This code will first show you the pre and post images and current masks.
% Next, it will display the first time point and prompt you to enter the
% number of lines you will like to draw. Draw N lines. Then you will be given the later
% time point and will again be prompted to enter the number of lines you
% would like to draw. Then, the new masks will be overlapped and displayed,
% so you can see if the match is satisfactory or if you missed a podosome.

% You should use this code not only to account for podosomes that appear as
% multiples in one channel but elongated blobs in the second, but also to
% deal with clear podosome multiples that should be separated so their
% radius can be reasonably determined. 


  for j = 1:2
     for k = 1:3
         for l=1:length(FinalMaskMat{1}{j,k});
             
             close all
             
                          x1= 50; y1=-20; GG=get(0,'Screensize');
                      set(gcf, 'Position', GG);
             FinalMaskMat{1}{j,k}{l}=bwmorph(FinalMaskMat{1}{j,k}{l},'diag');
             FinalMaskMat{2}{j,k}{l}=bwmorph(FinalMaskMat{2}{j,k}{l},'diag');
             
              subplot(2,4,1); imshow(indivcells{j,k}{l}{1,2},[100 1200]);
              title(strcat(num2str(j),  num2str(k) ,num2str(l)));
              subplot(2,4,2); imshow(indivcells{j,k}{l}{3,2},[100 1200]);
              title(strcat(num2str(j),  num2str(k) ,num2str(l)));
              subplot(2,4,5); imshow(FinalMaskMat{1}{j,k}{l});
              subplot(2,4,6); imshow(FinalMaskMat{2}{j,k}{l});
              pause(3)
              
              for PrePost=1:2
                          subplot(2,4,[3 4 7 8]); 
                          imshow(FinalMaskMat{PrePost}{j,k}{l});
                          
                         CMAPhere=[0 0 0; 1 0 0 ; 1 1 1];
                    colormap(gca, CMAPhere); colorbar
                 
                     saveto = {'How many lines do you need?'};
                    dlg_title = 'Lines';
                            num_lines = 1;
                            LineCt = inputdlg(saveto,dlg_title,num_lines);
                           Lines=str2double(LineCt);
                        for jj=1:Lines
                        h=imline;
                        pos{jj}=h.getPosition;
                        y1=pos{jj}(:,1); x1=pos{jj}(:,2);
                        [cx, cy, c]=improfile(FinalMaskMat{PrePost}{j,k}{l}, x1, y1);
                        cx2=cx-1;

                        for kk=1:length(cx)
                            FinalMaskMat{PrePost}{j,k}{l}(round(cx(kk)), round(cy(kk)))=0;
                            FinalMaskMat{PrePost}{j,k}{l}(round(cx(kk)-1), round(cy(kk)))=0;
                            title(strcat(num2str(j),' ',num2str(k),' ',num2str(l)));
                        end
                        end
              end
            close
            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(1,3,1); imshow(FinalMaskMat{1}{j,k}{l});
            subplot(1,3,2); imshow(FinalMaskMat{2}{j,k}{l});
            subplot(1,3,3);  imshow(FinalMaskMat{1}{j,k}{l}+2.*FinalMaskMat{2}{j,k}{l},[0 3]);
            colormap(gca, CMAPhere);
            pause(2)
              %}
         end
     end
  end


%% Find corresponding podosomes and quantify their properties 
  clear Overlapcentroids PodProps_A PodProps_Cent PodProps_Rd PodProps_Dist MatLoad
  MatLoad=cell(2,3)
  for j=1:2 % PCB or Regular Biotin
      for k=1:3 % Rep
          
          % Define cell arrays to store information about podosomes
          MatLoad{j,k}=cell(1,2) % This will contain podosome identifiers
          PodProps_A{j,k}=[]; % Area
          PodProps_Cent{j,k}=[]; % Centroid 
          PodProps_Rad{j,k}=[]; % Radius
          PodProps_Dist{j,k}=[]; % Distance from ROI
          
          for  l =1:length(FinalMaskMat{1}{j,k})
               
              % With this if statement, I skip cells where pods just aren't clearly
              % distinguished from other loss of signal and masking is
              % poor. Therefore, only clearly masked  cells are processed.
              
              if ~((j==1&& k==3 && l==2)||(j==1&& k==3 && l==6)||(j==2&& k==3 && l==1)||(j==2&& k==3 && l==7)||(j==2&& k==3 && l==8)) 
                  
                  % Make a mask of the overlaped podosome mask at -12 {1}
                  % and 29 {2} s. 
                  OverlapCutPods{j,k}{l}=FinalMaskMat{1}{j,k}{l}.*FinalMaskMat{2}{j,k}{l};
                  % Use region props to find the centroid of each podosome
                  % in this overlap mask. 
                  centersarray = regionprops(logical(OverlapCutPods{j,k}{l}),'centroid');
                  Overlapcentroids{j,k}{l} = cat(1, centersarray.Centroid);
             
              
                  for PrePost=1:2 %1 = -12 s = Pre, 2 = 29 s = Post
                        TC=length(MatLoad{j,k}{PrePost})+1; % This keeps track of the number of podosomes per cell. "Total Count"
                        % Label the podosome mask for this cell
                        L{j,k}{PrePost,l}=bwlabel(FinalMaskMat{PrePost}{j,k}{l});
                        
                            % Match up podosome identifiers in the masked
                            % image here with the overlapped mask image by
                            % finding the podosome N in L that corresponds
                            % to the centroid of each overlapped podosome.
                            % This will ensure you are comparing apples to
                            % apples later on. 
                            
                            for pod=1:length(Overlapcentroids{j,k}{l})
                                c1= round(Overlapcentroids{j,k}{l}(pod,1));
                                r1= round(Overlapcentroids{j,k}{l}(pod,2));
                                PodN=L{j,k}{PrePost,l}(r1, c1);
                                figure(1);
                              
                                % One problem that occured for me in developing this strategy was  that rounding the centroid could cause the podosome to be 'missed' in certain cases. To avoid this situation, go through the possible combinations of rounding up and roounding down to find the appropriate identifier.  
                               
                                if PodN==0
                                    c1= floor(Overlapcentroids{j,k}{l}(pod,1));
                                    r1= floor(Overlapcentroids{j,k}{l}(pod,2));
                                     PodN=L{j,k}{PrePost,l}(r1, c1);
                                end
                               
                                if PodN ==0 
                                     c1= round(Overlapcentroids{j,k}{l}(pod,1));
                                    r1= floor(Overlapcentroids{j,k}{l}(pod,2));
                                     PodN=L{j,k}{PrePost,l}(r1, c1);
                                end
                                
                                if PodN ==0 
                                     c1= floor(Overlapcentroids{j,k}{l}(pod,1));
                                    r1= round(Overlapcentroids{j,k}{l}(pod,2));
                                     PodN=L{j,k}{PrePost,l}(r1, c1);
                                end
                                
                                % Since each overlap podosome was mapped by
                                % the pre and post maps, each podosome must
                                % find a matching identifier. If rounding
                                % still doesn't solve the problem, do some
                                % looping to find the nearest podosome.
                                
                                tryme=[0 1 -1];
                                ct=1; add1=1; add2=1;
                                while PodN==0
                                            c1=c1+tryme(add1); r1= r1+tryme(add2);
                                            c1=round(c1); r1=round(r1);
                                            if rem(ct,2)==0
                                                add1=add1+1;
                                            else
                                                add2=add2+1;
                                            end
                                            ct=ct+1;
                                            PodN=L{j,k}{PrePost,l}(r1,c1);
                                end
                       % Finally, now that you have identified the
                       % podosome, go ahead and use MATLABs built in region
                       % analyzier, region props, to collect some data on
                       % this region. 
                        PodoProperties=regionprops(L{j,k}{PrePost,l}==PodN, 'centroid','area','majoraxislength','minoraxislength','eccentricity');
                        PodProps_E{j,k}(PrePost,TC)=PodoProperties.Eccentricity;
                        PodProps_A{j,k}(PrePost,TC)=PodoProperties.Area;
                        PodProps_Cent{j,k}{PrePost,TC}=PodoProperties.Centroid;
                        PodProps_Rad{j,k}(PrePost,TC)=mean([PodoProperties.MajorAxisLength PodoProperties.MinorAxisLength],2);
                        PodProps_Dist{j,k}(PrePost,TC)=pdist([PodProps_Cent{j,k}{PrePost,TC}; ROcenter{j,k}{l,1}],'euclidean'); % Distance from centroid of PC region.
                        MatLoad{j,k}{PrePost}(TC,:)=[j; k; l; PodN]; % Keep track of the podosome's identity. j = condition, k = rep, l = cell number, PodN = PodN in L. 
                        
                        TC=TC+1 % Keeps track of total number of podosomes in that bioreplicate sample to store in properties matrix. 
                end
                
              end
              
               
             
          end
      end
      end
  end
  %% Get rid of any podosomes counted twice which indicates that they are not properly masked or aligned. 
  
 for j=1:2
     for k=1:3
         for PrePost=1:2
             BarCoded{j,k}{PrePost}= Row2Numb(MatLoad{j,k}{PrePost});
             FD{j,k}{PrePost}=FindDups(BarCoded{j,k}{PrePost});
             for l=1:length(FD{j,k}{PrePost})
                 
                 r=FD{j,k}{PrePost}(l)
                 
                 PodProps_E{j,k}(PrePost,r)=nan;
                       
                        
                        PodProps_A{j,k}(PrePost,r)=nan;
                        PodProps_Cent{j,k}{PrePost,r}=nan;
                        PodProps_Rad{j,k}(PrePost,r)=nan;

                        PodProps_Dist{j,k}(PrePost,r)=nan;
                
             end
                 
         end
     end
 end
 


%% Check Podosome Matching 
% This is a challenging image analysis problem, because it is hard to
% clearly identify podosomes individually by depletion, and because
% podosomes are dynamic. Therefore, this code does an excellent job, but is
% not perfect. You can use this section to visually evaulate how well your
% matching worked. I did not quantify but would estimate we had about %85
% percent success, which exceeds literature standard for podosome
% identification and is reasonable to use. 

% Because of the number of podosomes, this will take a long time to view, so adjust pause time and enter in one
% group at a time using j and k to check visually. 
for j=1
    for k=3
       close all
               for l=1:length(MatLoad{j,k}{1,1})
                   pk=RandColorScale();
                    for PrePost=1:2
               PodNHere(PrePost)= MatLoad{j,k}{PrePost}(l,4); 
               CellN(PrePost)= MatLoad{j,k}{1,PrePost}(l,3);
               
               Bpods = bwboundaries(FinalMaskMat{PrePost}{j,k}{CellN(PrePost)});
               subplot(1,2,PrePost); imshow(L{j,k}{PrePost,CellN(PrePost)}==PodNHere(PrePost))
           
               hold on
               for bp=1:length(Bpods)
               plot(Bpods{bp}(:,2), Bpods{bp}(:,1),'r');
               
               end
               
               Bpods=[];
              
               
                    end
                    pause(0.5);
               end
    end
end
           %{
            %  x1= 50; y1=-50; GG=get(0,'Screensize');
                 %      set(gcf, 'Position', GG);
                        w=waitforbuttonpress;
                         FinalMaskMat2{PrePost}{j,k}{CellN(PrePost)}=FinalMaskMat{PrePost}{j,k}{CellN(PrePost)};
                        if w==1
                            for PrePost=1:2
                              
                                 
                            FinalMaskMat2{PrePost}{j,k}{CellN(PrePost)}(L{j,k}{PrePost,CellN(PrePost)}==PodNHere(PrePost))=0;
                              end
                            end
                        end
         
           
        end
           
    end
          
  %}

%% Plotting: Distance from ROI origin versus percent change in radius (Not included in paper, but shows clear trend and is a useful graph)
  
  for j=1:2
      for PrePost=1:2
            PodosomeProperties_Radii{j,PrePost}= [PodProps_Rad{j,1}(PrePost,:), PodProps_Rad{j,2}(PrePost,:), PodProps_Rad{j,3}(PrePost,:)];
            PodosomeProperties_Dist{j,PrePost}= [PodProps_Dist{j,1}(PrePost,:), PodProps_Dist{j,2}(PrePost,:), PodProps_Dist{j,3}(PrePost,:)];
            PodosomeProperties_Area{j,PrePost}= [PodProps_A{j,1}(PrePost,:), PodProps_A{j,2}(PrePost,:), PodProps_A{j,3}(PrePost,:)];
      end
      PercDeltaR{j}=100.*(PodosomeProperties_Radii{j,2}-PodosomeProperties_Radii{j,1})./PodosomeProperties_Radii{j,1};
      PercDeltaA{j}=100.*(PodosomeProperties_Area{j,2}-PodosomeProperties_Area{j,1})./PodosomeProperties_Area{j,1};
  end
  CCC=[1 0 0;  0 0 0];
  close all
  hold on
  
  figure(1)
   plot([3.7618 3.7618],[-100 250],'--','Color',[.5 .5 .5],'LineWidth',1,'MarkerSize',20); hold on;

  for j=1:2
      figure(1)
     
 plot(PodosomeProperties_Dist{j,1}.*.14, PercDeltaR{j},'.','Color',CCC(j,:)); hold on
 xlabel('Distance from ROI Origin (um)','FontName','Arial','FontSize',14); ylabel('Percent Change in Radius','FontName','Arial','FontSize',14);
 figure(2)
 plot([3.7618 3.7618],[-100 250],':','Color',[.5 .5 .5],'LineWidth',1);
  plot(PodosomeProperties_Dist{j,1}*.14, PercDeltaA{j},'o','Color',CCC(j,:)); hold on
  end
  figure(1);
  legend('ROI Radius','Photocleavable Biotin','Control')
 
  legend boxoff
           
%% Plotting: Change in radius by experimental group - ALL (SI)
 close all
 MATRI={PercDeltaR_ROI, PercDeltaR_Distal};
 for j=1:2
     for k=1:2
     outl=find(isoutlier(MATRI{j}{k}));
         for l=1:length(outl)
             MATRI{j}{k}(outl(l))=nan;
         end
     end
 end
 
 figure(99); hold on
PDall=PaddedBoxPlot({MATRI{1}{1}, MATRI{2}{1}, MATRI{1}{2}, MATRI{2}{2}});
 for j=1:2
     p=PDall{j};
     PDall{j}=[]; PDall{j}=p';
 end
PDall{1}=PDall{1}'; PDall2=PDall{2}';
 pdlen=length(PDall{1})
 for j=1:4
     if ismember(j,[1 3])
     scatter([j.*ones(1,length(PDall{1}))],PDall{j},5,'black','filled','jitter','on','jitterAmount',.15);
     else
         scatter([j.*ones(1,length(PDall{1}))],PDall{j},5,'red','filled','jitter','on','jitterAmount',.15);
     end
 end
    xlim([0 5]); ylim([-80 60]); 
    %{
 %Stats
 %1. Experimental - ROI vs Distal
 [hpe ppe]=ttest2(MATRI{1}{1}, MATRI{2}{1});
 plot([1 2],[35 35],'-k');
 text(1.5, 40,SigStars(ppe));
 %2. Control - ROI vs Distal
 [hpc ppc]=ttest2(MATRI{1}{2}, MATRI{2}{2});
  plot([3 4],[50 50],'-k');
 text(3.5, 55,SigStars(ppc));
 %3. Exp ROI vs Control ROI
 [hpceR ppceR]=ttest2(MATRI{1}{2}, MATRI{1}{1});
   plot([3],[50 50],'-k');
 text(3.5, 55,SigStars(ppc));
 %4. Exp Dist vs Control DistFriday19g
    
 
    %}
 clear   Mat2Stat
% 
% Prep Data 
    %Column is Region
    % Row is Exp (top) , Control (bottom)
    % N samples = pdlen
    clear Mat2Stat g2 g1
    Mat2Stat=[MATRI{1}{1}'; MATRI{2}{1}'; MATRI{1}{2}';MATRI{2}{2}'];
    Loc={'P','D'}; Samp={'Exp','Cont'};
   % 89 99 172 155
    for j=1:89
        g1{j}='P';
        g2{j}='Exp';
    end
    for j=90:261
        g1{j}='D';
        g2{j}='Exp';
    end
    for j=262:360
        g1{j}='P';
        g2{j}='Cont';
    end
    for j=361:515
        g1{j}='D';
        g2{j}='Cont';
    end
    figure(1)

[~,~,stats] = anovan(Mat2Stat,{g1, g2}, 'model','full','varnames',{'ROI','Probe'})
results = multcompare(stats,'Dimension',[1 2])

figure(60); hold on
 for j=1:4
     if ismember(j,[1 3])
     scatter([j.*ones(1,length(PDall{1}))],PDall{j},5,'black','filled','jitter','on','jitterAmount',.15);
     else
         scatter([j.*ones(1,length(PDall{1}))],PDall{j},5,'red','filled','jitter','on','jitterAmount',.15);
     end
 end
    xlim([0 5]); ylim([-80 60]); 
N=[1 2 5 6];
    for j=1:4
hold on
plot([results(N(j),1), results(N(j),2)],[40+(j-1)*5 40+(j-1)*5],'k')
text(mean([results(N(j),1), results(N(j),2)]),40+(j-1)*5+3,SigStars(results(N(j), 6)));
MeansRad(j)= mean(PDall{j},'omitnan');
plot([j-.15 j+.15], [MeansRad(j) MeansRad(j)]);
    end
%% Plotting: Change in radius - Main Fig - Only PC Biotin groups
 
close all

 for k=1:2
      CleaveROIPods{k}=(PodosomeProperties_Dist{k,1}.*.14)<3.7618;
      PercDeltaR_ROI{k}=PercDeltaR{k}(CleaveROIPods{k});
      PercDeltaR_Distal{k}=PercDeltaR{k}(~CleaveROIPods{k});
      
 end
 close all

 colormap(gca, jet);
 PDR=PercDeltaR_ROI{:,1};
 PDD=PercDeltaR_Distal{:,1};
 PDRO=find(isoutlier(PDR)); PDDO=find(isoutlier(PDD));
 for j=1:length(PDRO)
     PercDeltaR_ROI{1}(PDRO(j))=nan;
 end
  for j=1:length(PDDO)
     PercDeltaR_Distal{1}(PDDO(j))=nan;
 end

 figure(3)
 PD=PaddedBoxPlot({PercDeltaR_ROI{1,1}, PercDeltaR_Distal{1,1}});
pd=length(PD{1});

hold on
scatter([1.*ones(1,pd)], [ PD{:,1}],5, 'red','filled','jitter','on', 'jitterAmount', 0.15);

scatter([2.*ones(1,pd)], [ PD{:,2}],5, 'red','filled','jitter','on', 'jitterAmount', 0.15);
xlim([0 3])
xticks([1 2])

hold on 
MEANCHANGE=[mean(PercDeltaR_ROI{:,1},'omitnan') mean(PercDeltaR_Distal{:,1},'omitnan')];
plot([.7 1.3], [MEANCHANGE(1) MEANCHANGE(1)]);
plot([1.7 2.3], [MEANCHANGE(2) MEANCHANGE(2)]);
plot([1 2],[42 42], '-k');
text(1.5, 45,SigStars(results(N(1),6)),'HorizontalAlignment','Center')
xticklabels({'Local','Distal'});
ylabel('Percent Change (Radius)','FontName','Arial','FontSize',14);
ylim(100.*[-0.75 .5])


%% Some code to plot images w ROI boxed

 close all

    figure(1); imshow(indivcells{1,1}{1,5}{1,1},[0 1000]);
    figure(2); imshow(indivcells{1,1}{1,5}{1,2},[100 1000]); 
    hold on
    BBB= bwboundaries(indivcells{1,1}{1,5}{1,3});
    plot(BBB{1}(:,2), BBB{1}(:,1),'r')
    
    figure(3); imshow(indivcells{1,1}{1,5}{3,1},[0 1000]);
    figure(4); imshow(indivcells{1,1}{1,5}{3,2},[100 1000]); 
    hold on
    BBB= bwboundaries(indivcells{1,1}{1,5}{1,3});
    plot(BBB{1}(:,2), BBB{1}(:,1),'r')
   


