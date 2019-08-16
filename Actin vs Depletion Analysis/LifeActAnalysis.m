%% Objective: Plot the relationship between actin intensity and RGD depletion. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Bring in Data

% Address and load your data using BioFormats
clear
ssDNAmCerA= 'C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\TransfectionData\180221_mCeruleanActin';
F={'B-Cy3B-RGD','B-Cy3B-RGD2','B-Cy3B-RGD3'}
ActinData={};
for j=1:3
    Ims= FindFiles(fullfile(ssDNAmCerA,F{j}),'*.nd2');
    for k=1:length(Ims)
    RD=bfopen(Ims{k});
    for l=1:3
        ActinData{j,k}{1,l}=RD{1,1}{l,1};
    end
    end
end
%% Select cells with mCerulean Actin expression
close all
ct=1;
SZ= size(ActinData);
for jj=1:SZ(2)
    for j=1:SZ(1);
        if ~isempty(ActinData{j,jj})
  m=min(ActinData{j,jj}{1,2}(:)); M=max(ActinData{j,jj}{1,2}(:));
   for box=1:3
       Means(box)=MeanIOnly(double(ActinData{j,jj}{1,2}), m,M);
       close
   end
    imshow(ActinData{j,jj}{1,3},[]);
    figure(1); fig=gcf;
    fig.Units='normalized';
fig.OuterPosition=[0 0 1 1]; 
   BackgroundVal=mean(Means);
    saveto = {'# Cells'};
dlg_title = 'Cell Ct';
num_lines = 1;
CellCt = inputdlg(saveto,dlg_title,num_lines);
CellNumber=str2double(CellCt{1});      
    for k=1:CellNumber
    coord=getPosition(imrect);
    ROIcoords=round([coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)]);
    x1=coord(1); x2=coord(1)+coord(3); y1=coord(2); y2=coord(2)+coord(4);
    x = [x1, x2, x2, x1, x1];
    y = [y1, y1, y2, y2, y1];
    hold on;
    plot(x, y, 'b-', 'LineWidth', 1);
    hold on;
    for jjj=1:3
    IndivCell{ct}{1,jjj}=double(ActinData{j,jj}{1,jjj}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2)));
    end
    IndivCell{ct}{1,4}=IndivCell{ct}{1,3}./max(IndivCell{ct}{1,3}(:));
    IndivCell{ct}{1,5}=IndivCell{ct}{1,2}./BackgroundVal;
    ct=ct+1;
    
    end
close
end
    end
end
%% Save Important Variables
save('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\MatLabVars\mCerLifeActVars181027.mat','IndivCell','ActinData');
%% Import Variables
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\MatLabVars\mCerLifeActVars.mat');

%% Find background intensity in RGD Ims (corners)
   
   
% We did not save the deviations above, so here find the mean and
% deviations again...But, this is actually better because previously you
% selected from the LifeAct channel, but there is some aggretation in the
% RGD channel here (we suspect this could possibly be due to very trace
% PEI???), so this way this value will be indep - select a relatively
% clean litle rectangle in the corner of the image. 


for k=1:length(IndivCell)
    [B(k) Dev(k)]=MeanI(IndivCell{k}{1,2});
    close
end

%% Separate podosome multiples with a 2 pixel wide line


close all
for k=1:25
    % Mask based on RGD intensity. I found this cutoff works 
    % here, but you may need to find a different cutoff for your data
    % set. 
IndivCell{k}{1,6}=IndivCell{k}{1,2}<(B(k)-3.5*Dev(k)); % Threshold to find podosomes
    % Remove small objects (2 pix or less. Again, customize as needed).
IndivCell{k}{1,7}=bwareaopen(~IndivCell{k}{1,6},2); % Clear small objects

    % View Images briefly.
subplot(1,2,1); imshow(IndivCell{k}{1,6},[]);  
subplot(1,2,2); imshow(IndivCell{k}{1,7},[]);
pause(1);
close


fig=gcf;
fig.Units='normalized';
fig.OuterPosition=[0 0 1 1]; 
suptitle('Draw a continuous line to separate the podosome multiples, Ch. 3. Enter to continue')
% Some podosomes will be hard to separate, but do the best you can. If you
% are completely unsure in a region, just leave them as a blob and you will
% not use them later in analysis. 
subplot(1,3,1); imshow(IndivCell{k}{1,4});
subplot(1,3,2); imshow(IndivCell{k}{1,2},[]);
subplot(1,3,3); imshow(IndivCell{k}{1,7});

SliceMask{k}=zeros(size(IndivCell{k}{1,1}));
Yvals=[];
[cx,cy,c] = improfile();
cx=round(cx); cy=round(cy);
for l=1:length(cx);
              
SliceMask{k}(cy(l), cx(l))=1; 


end
% Dilate slice mask - 2 pix wide total.
SM{k}=imdilate(SliceMask{k},strel('disk',1));
% Multiply RGD image by your mask (inverted).
IndivCell{k}{1,8}=(~IndivCell{k}{1,7}.*IndivCell{k}{1,2});
% Multilply this mask by your inverted dilated slice mask to separate
% podosomes. 
IndivCell{k}{1,9}=IndivCell{k}{1,8}.*~SM{k};
close;
imshow(IndivCell{k}{1,9});title('Click to continue'); waitforbuttonpress;
end

%% Label and select the easily distinguishable podosomes

% Look at all the channels and masks to select the 'most identifiable'
% individual podosomes. If something is a mush of fluorescence and is in very poor focus or has been overly or
% under separated such that it poorly reflects the raw data, do not select
% it. 


for k=1:length(IndivCell)
suptitle('Select clear podosomes in the Mask channel based on signal from other 3 channels. Enter to proceed.');
    subplot(2,2,1); imshow(IndivCell{k}{1,5},[]); title('Norm. RGD');   subplot(2,2,2); imshow(IndivCell{k}{1,4},[]); ('Norm LifeAct');
subplot(2,2,3); imshow(IndivCell{k}{1,9},[]); ('Mask * Norm RGD');
    subplot(2,2,4); imshow(Lab{k},[]); ('Mask');
    colormap(gca, 'jet');
    
    fig=gcf;
    fig.Units='normalized';
    fig.OuterPosition=[0 0 1 1]; 
    pause(3);
    [c r]=ginput();
    r=round(r); c=round(c);
    for l=1:length(r);
    Pods{k}(l)=Lab{k}(r(l),c(l));
    end
    close
end

%% Individual Podosome Quantification 

for j=1:length(IndivCell)
    if ~isempty(Pods{j}) %Filter for cells in good focus/well isolated pods to quantify. If empty, did not select pods due to quality and clarity. 
    Pods{j}=unique(Pods{j}); Pods{j}(Pods{j}==0)=[]; % Make sure that if a podosome was clicked multiple times, it is only processed once
        for z=1:length(Pods{j})%Quantify properties of each podosome
            POD=zeros(size(PodoMasks{j})); POD(POD==0)=NaN; %Use the mask to quantify each individual podosome
            p=Pods{1,j}(z);
            POD(Lab{j}==p)=1; %Find that single podosome 
            POD2=POD; POD2(isnan(POD2))=0;
            PR=regionprops(logical(POD2),'MajorAxisLength','MinorAxisLength'); %Region props of the podosome. This requires that you use a logical, hence POD2. 
            MAL=PR.MajorAxisLength; MIL=PR.MinorAxisLength;
            Rad{j}(z)=.5*(MAL+MIL); %Find Radius of podosome
            RGDNorm_Data{j}{z}=POD.*((IndivCell{j}{1,2})./B(j)); %Find Mean intensity of RGD in that podosome by multiplying the mask by the normalized RGD image. 
            MeanRGD{j}(z)=mean(RGDNorm_Data{j}{z}(:),'omitnan');
            if MeanRGD{j}(z)~=0
            Dep{j}(z)=1-MeanRGD{j}(z); %How much is depleted (on average)
            end
            PodArea{j}(z)=sum(POD(:),'omitnan').*(.14)^2 ;%Find total podosome area; Note: Input your pixel size here. I realize that my pixel size is not 0.14 in every image after the fact, but since this data gets normalized on a per image basis, this is not a problem. 
            Podoso= POD.*(IndivCell{j}{1,3}); %Multiply actin image by the pod mask. 
            MeanAct{j}(z)=mean(Podoso(:),'omitnan'); %Calculate the mean podosome actin intensity.
        end
    end
end
%% Find Outstanding Podsomes per Cell
for j=1:25
    if isempty(Dep{j})
        BigPod(j)=nan; BrightPod(j)=nan; BigRadPod(j)=nan;
    else
        BrightPod(j)=find(MeanAct{j}==max(MeanAct{j})); %Brightest Podosome BY ACTIN
        BigRadPod(j)= find(Rad{j}==max(Rad{j}));
        if uint8(sum((PodArea{j}==max(PodArea{j}))))==1
        BigPod(j)=find(PodArea{j}==max(unique(PodArea{j}))); % Biggest Podosome BY AREA
        else %if two have the same radius count the bigger one as the one with the bigger radius
            MaxCands=Rad{j}(find(PodArea{j}==max(PodArea{j})));
            BigPod(j)=find(max(MaxCands));
            clear MaxCands;
        end
    end
end
%% NORMALIZE BY BRIGHTEST (ACTIN CONTENT)
Dep_NBr_Vect=[]; Act_NBr_Vect=[]; Rad_NBr_Vect=[]; 
for j=1:25
    if isempty(Dep{j})
        Act_NormBright{j}=nan;
        Dep_NormBright{j}=nan;
        Rad_NBr{j}=nan;
    else
        Act_NormBright{j}=MeanAct{j}./MeanAct{j}(BrightPod(j));
        Dep_NormBright{j}=Dep{j}./Dep{j}(BrightPod(j));
        Rad_NBr{j}=Rad{j}./Rad{j}(BrightPod(j));
    end
    Dep_NBr_Vect=[Dep_NBr_Vect Dep_NormBright{j}];
    Rad_NBr_Vect=[Rad_NBr_Vect Rad_NBr{j}];
    Act_NBr_Vect=[Act_NBr_Vect Act_NormBright{j}];
    Dep_NBr_Vect=Dep_NBr_Vect(~isnan(Dep_NBr_Vect));
    Rad_NBr_Vect=Rad_NBr_Vect(~isnan(Rad_NBr_Vect));
    Act_NBr_Vect=Act_NBr_Vect(~isnan(Act_NBr_Vect));
end
%% Plot actin versus depletion. 

% Click once to add R^2, Click once to add R. 
close all

subplot(1,2,1);
scatter(Act_NBr_Vect, Dep_NBr_Vect);
xlim([0.5 1]); axis square
hold on
LinearFit_Plot(Act_NBr_Vect, Dep_NBr_Vect,'k')

xlabel('Normalized Actin');
ylabel('Mean Depletion');
r= corrcoef(Act_NBr_Vect, Dep_NBr_Vect);
[x y]=ginput();
text(x,y,strcat('r = ',num2str(r(1,2))))


subplot(1,2,2);
scatter(Dep_NBr_Vect, Rad_NBr_Vect);
xlim([0.5 1.2]); axis square
hold on
LinearFit_Plot(Dep_NBr_Vect, Rad_NBr_Vect,'k')

xlabel('Normalized Percent Depletion');
ylabel('Normalized Depletion Radius');
r= corrcoef(Dep_NBr_Vect, Rad_NBr_Vect);
[x y]=ginput();
text(x,y,strcat('r = ',num2str(r(1,2))))





