%% This code is used to process tenson gauge tether data.  
% Input is 2 ch images (.nd2): 1. RICM 2. Fluorescence.
% % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Load data

% Data organization:

% One folder each for 12 and 56 pN, which contains 3 subfolders each
% corresponding to a bioreplicate.
%clear all
ct=1;
FN56='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\TGTRawData\56pN';
FN12='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\TGTRawData\12pn';
F56={'171226_56pN_2hr', '171227_56pN_1_2hr', '171227_56pN_2_2hr'};
F12={'171226_12pN_2hr', '171227_12pN_1_2hr', '171227_12pN_2_2hr'}; 
Im12=LoadTriplicateBS(FN12,F12);
Im56=LoadTriplicateBS(FN56,F56);
%% Select Cells and Backgrounds

% Run this for each cell you are imaging. You could write a loop to do
% this, but that slows down my computer. In addition, if you make a mistake thiss make for easy correction. 

% Images w a bunch of SLB junk that could be mistaken for pods or with half photobleaching were excluded and that spot is
% marked as NaN in the cell. If channels are reversed also entered as nan.
% If an image is a repeat it is nan. 
close all
% User prompt to enter:
    % 1. Cond = Condition (12 or 56)
    % 2. Rep = Replicate (1 - 3)
    % 3. Image N = Image Number (We processed images 1-20)
    
    % After entering, the images will pop up in a subplot: Left - RICM,
    % Righ - Fluorescence. 
    % The code will prompt you to enter the number of cells to analyze.
    % Then, for each of these cells, 1) Draw a polygon around the cell in
    % RICM, 2) Grab a local background 
    
prompt={'Cond','Rep','ImageN'};
name='Input';
num_lines = 13;
dlg_ans=inputdlg(prompt,name, 1);

Condi=str2num(dlg_ans{1});
Rep=str2num(dlg_ans{2});
ImageN=str2num(dlg_ans{3}); 
clearvars -except Condi Rep ImageN ct FN56 FN12 F56 F12 Im12 Im56 TGT12 TGT56 Rep ImageN PodCount PodNums PodArea PodCount56 PodNums56 PodArea56
if (Condi==12 && Rep==2 && ImageN==16) ||(Condi==12 && Rep==2 && ImageN==4) 
    Fluor=Im12{Rep,ImageN}{1,1};
    RICM=Im12{Rep,ImageN}{2,1};
elseif Condi==12
    Fluor=Im12{Rep,ImageN}{2,1};
    RICM=Im12{Rep,ImageN}{1,1};
else
    Fluor=Im56{Rep,ImageN}{2,1};
    RICM=Im56{Rep,ImageN}{1,1};
end
fig=gcf;
fig.Units='normalized';
fig.OuterPosition=[0 0 1 1];
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
subplot(1,2,1); imshow(RICM,[]);
subplot(1,2,2); imshow(Fluor,[]);
subplot(1,2,1);
saveto = {'# Cells to Analyze'};
dlg_title = 'Cell Ct';
num_lines = 1;
CellCt = inputdlg(saveto,dlg_title,num_lines);
CellNumber=str2double(CellCt{1});
CellSpots=cell(CellNumber);
CtsMask=cell(CellNumber);
for l=1:CellNumber
    subplot(1,2,1);
    CellMask{l}=roipoly;
    
    Bound=bwboundaries(CellMask{l});
    subplot(1,2,1);
    hold on
    plot(Bound{1}(:,2), Bound{1}(:,1),'r');
    subplot(1,2,2);
    hold on
    plot(Bound{1}(:,2), Bound{1}(:,1),'r');
    [Ba Bd]=MeanIOnly(Fluor);
    B{l}=Ba;
    Bd{l}=Bd;
end

close
T=TGTCells(RICM,Fluor);
T.B=B;
T.CellMask=CellMask;
T.Rep=Rep;
T.ImageN=ImageN;
T.B = B;
T.BDevs = Bd;
if Condi==12
    TGT12{Rep,ImageN}=T;
else
    TGT56{Rep,ImageN}=T;
end
%% Make a large variable with all of these TGTCells
QuantDat={TGT12, TGT56};
%% Which cells have podosomes? 

% Here we determine which cells have podosomes. Podosome quantification is
% in a later section.

for jj=1 %Enter: 1 for 12 pN or 2 for 56 pN 
for j=1:3 %Rep
    cell_ct=1;
    for k=1
        if ~isempty(QuantDat{jj}{j,k})
            QuantDat{jj}{j,k}.RTherePods=[];
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            imshow(QuantDat{jj}{j,k}.Fluor,[]);
              for l=1:length(QuantDat{jj}{j,k}.CellMask)
                Bound=bwboundaries(QuantDat{jj}{j,k}.CellMask{l});
                hold on
                plot(Bound{1}(:,2), Bound{1}(:,1),'r');
                saveto = {'Pods'};
                dlg_title = 'Does this cell have podosomes? (1 = Yes, 0 = No)';
                num_lines = 1;
                CellCt = inputdlg(saveto,dlg_title,num_lines);
                RPods(l)=str2double(CellCt{1});
              end
                QuantDat{jj}{j,k}.RTherePods=RPods;
                clear RPods
                close all
        end
    end
end
end
%% What percent forms pods? (Plot) 


for jj=1:2
    for j=1:3
        for k=1:20
        if ~isempty(QuantDat{jj}{j,k})
            for l=1:length(QuantDat{jj}{j,k}.B)
                if isnan(QuantDat{jj}{j,k}.RTherePods(l))
                    disp(l)
                end
                % I accidentally hit a 2 or just ok somewhere instead of 1.
                % Fix this error here. 
                if ~ismember(QuantDat{jj}{j,k}.RTherePods(l),[0 1])
                    QuantDat{jj}{j,k}.RTherePods(l)=1;
                end
            end
        end
        end
    end
end
% Compile 1s and 0s into lists to analyze
FormPods=cell(1,2); 
for jj=1:2
    for j=1:3
        FormPods{jj}{j}=[];
        for k=1:20
            if ~isempty(QuantDat{jj}{j,k})
            FormPods{jj}{j}=[FormPods{jj}{j} QuantDat{jj}{j,k}.RTherePods];
            end
        end
    end
end

for jj=1:2
    for j=1:3
        PercentPodos(jj,j)=100*(sum(FormPods{jj}{j}(:))/length(FormPods{jj}{j}));
    end
end

Mean_PercentForm=mean(PercentPodos,2);
SDev_PercentForm=[std(PercentPodos(1,:)); std(PercentPodos(2,:))];
[hPercentForm pPercentForm]=ttest2(PercentPodos(1,:), PercentPodos(2,:)); 
close all
% Plot
figure(1); 
parula=parula;
PAR=parula;
ErrorBars(Mean_PercentForm, SDev_PercentForm,[PAR(5,:); PAR(5,:)], {'12 pN','56 pN'});
hold on; 
for j=1:2
    scatter(ones(1,3).*j, PercentPodos(j,:),'jitter','on','jitteramount',0.1);
end
ylim([0 80]);
ylabel('Percent Podosome Forming');
%% Generate Pod Indexes
% These variables are used to identify which cells have and do not have
% podosomes.
for jj=1:2
    PY{jj}=[]; PN{jj}=[];
    for j=1:3
        PodYes{jj}{j}=FormPods{jj}{j};
        PodYes{jj}{j}(PodYes{jj}{j}==0)=nan;
        PodNo{jj}{j}=double(~FormPods{jj}{j});
        PodNo{jj}{j}(PodNo{jj}{j}==0)=nan;
        PY{jj}=[PY{jj} PodYes{jj}{j}];
        PN{jj}=[PN{jj} PodNo{jj}{j}];
    end
end
%% Quantify and plot Cell Area 
% Copy matricies and run stats in matlab
% Calculate the cell area
CellArea=cell(1,2); 
for jj=1:2
    for j=1:3
        CellArea{jj}{j}=[];
        for k=1:20
            if ~isempty(QuantDat{jj}{j,k})
                for l=1:length(QuantDat{jj}{j,k}.CellMask)
                    CellSpot=QuantDat{jj}{j,k}.CellMask{l}(:);
                    CellA(l)=sum(CellSpot).*.16^2; % Input your pixel size here
                end
                    CellArea{jj}{j}=[CellArea{jj}{j} CellA];
                    clear CellA
            end
        end
    end
end


% Determine area by score - No = No podosomes, Yes = Contains podosomes. 
for jj=1:2
    A_Yes{jj}=[]; A_No{jj}=[]; A_All{jj}=[];
    for j=1:3
        PYA{j,jj}= CellArea{jj}{j}.*PodYes{jj}{j};
        PNA{j,jj}= CellArea{jj}{j}.*PodNo{jj}{j};
        % For "all" use CellArea Matrix
    A_Yes{jj}=[A_Yes{jj} PYA{j,jj}];
    A_No{jj}=[A_No{jj} PNA{j,jj}];
    A_All{jj}=[A_All{jj} CellArea{jj}{j}];
    end
end

% Plot Area

%12 pN 56 pN Pods No Pods

Pad_A_All=PaddedBoxPlot(A_All);
scatter([ones(1,415),ones(1,415).*2], [Pad_A_All{:,1}, Pad_A_All{:,2}],20, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.25);
xlim([0 3]);
hold on
for j=1:2
    plot([j-.25 j+.25],[MeanCellArea_All(j) MeanCellArea_All(j)],'k');
end
plot([1 2],[650 650],'k');

%Not shown in paper:

% No Pods vs Pods
figure(40)
Pad_A_PnoP=PaddedBoxPlot({[A_No{1} A_No{2}],[A_Yes{1} A_Yes{2}]});
scatter([ones(1,747),ones(1,747).*2], [Pad_A_PnoP{:,1}, Pad_A_PnoP{:,2}],20, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.25);
xlim([0 3]);
hold on
plot([1-.25 1+.25],[NoPodCellArea NoPodCellArea],'k');
plot([2-.25 2+.25],[PodCellArea PodCellArea],'k');
plot([1 2], [650 650],'-k');
%} 

%% Count podosome number and identify location of centroid

%In this section of the code, you will be shown a fluorescence micrograph
%with a cell circled. Enter the number of podosomes. Then, click to zoom in
%as needed. Hit enter to set that zoom. Click to identify the centroid of
%the podosome. 
for jj=1 %12 (1) or 56 (2)    
for j=2 %Rep
    cell_ct=1;
    for k=1:12
        close 
        if ~isempty(QuantDat{jj}{j,k})
            QuantDat{jj}{j,k}.PodLoc=[];
            for l=1:length(QuantDat{jj}{j,k}.RTherePods)
                if QuantDat{jj}{j,k}.RTherePods(l)==0
                    QuantDat{jj}{j,k}.PodLoc{l}=nan;
                else
                  
                   imshow(QuantDat{jj}{j,k}.Fluor,[200 800]);
                   hold on
                   clear BB
                   BB=bwboundaries(QuantDat{jj}{j,k}.CellMask{l});
                   plot(BB{1}(:,2), BB{1}(:,1),'r');
                   % Confirm there are really pods there. If not, then note
                   % that and that will save into the data. If for any cells,  you made a mistake and don't actually see podosomes, make sure you go back and rerun the population stats, since they will change.  and then the
                  
                   saveto = {'Pods'};
                    dlg_title = 'Does this cell have podosomes?';
                    num_lines = 1;
                    CellCt = inputdlg(saveto,dlg_title,num_lines);
                    RPods=str2double(CellCt{1});
                    if RPods==1
             
                
                       [rr cc]=ZoomSelection(gcf);
                       QuantDat{jj}{j,k}.PodLoc{l}(:,1)=rr;
                       QuantDat{jj}{j,k}.PodLoc{l}(:,2)=cc;
                       clear rr cc
                    else
                         QuantDat{jj}{j,k}.PodLoc{l}=nan;
                         QuantDat{jj}{j,k}.RTherePods(l)=0;
                    end
                end
            end
        end
    end
end
end
        
%% Area of podosome-forming and non podosome forming cells.(Not used in manuscript. Plot) 
% Note: This graph does not appear in manuscript. 
for jj=1:2
    CellArea{jj}=[];
    for j=1:3
        for k=1:20
            if ~isempty(QuantDat{jj}{j,k})
                for l=1:length(QuantDat{jj}{j,k}.CellMask)
                    CellSpot=QuantDat{jj}{j,k}.CellMask{l}(:);
                    CellA(l)=sum(CellSpot).*.16^2;
                end
                    CellArea{jj}=[CellArea{jj} CellA];
                    clear CellA
            end
        end
    end
   
end
    close all
    PadAreas=PaddedBoxPlot({CellArea{1}.*PN{1}, CellArea{1}.*PY{1}, CellArea{2}.*PN{2}, CellArea{2}.*PY{2}});
    for sp=1:4
        PadAreas{sp}(find(isoutlier(PadAreas{sp})))=nan;
    end
    ct=1;
    
    for co=1:415
    COLO(ct,:)=[0 1 0];
    ct=ct+1;
    end
    for co=416:830
        COLO(ct,:)=[0 0 1];
    ct=ct+1;
    end
    for co=831:1245
        COLO(ct,:)=[0 1 0];
    ct=ct+1;
    end
    for co=1246:1660
        COLO(ct,:)=[0 0 1];
    ct=ct+1;
    end
    close all
    scatter([ones(1,415),ones(1,415).*2, ones(1,415)*4,ones(1,415).*5], [PadAreas{1}, PadAreas{2}, PadAreas{3}, PadAreas{4}],20,COLO,'filled','jitter','on', 'jitterAmount', 0.25);
xlim([0 6]);
ylim([0 500]);
ct=1;
for sp=[1 2 4 5]
    hold on
    plot([sp-.25 sp+.25],[median(PadAreas{ct},'omitnan') median(PadAreas{ct},'omitnan')],'-k');
    Norm(ct)=kstest((PadAreas{ct}-mean(PadAreas{ct},'omitnan'))./std(PadAreas{ct},'omitnan'));
    disp('plotted')
    ct=ct+1;
end
    
   
LineSpots=[1 4; 2 5; 1 2; 4 5];
heights=[370 400 230 410]

    %}    
% Perform statistics with a 2 way anova
 %Column is Region
    % Row is Exp (top) , Control (bottom)
  
    Mat2Stat=[PadAreas{1}, PadAreas{2}, PadAreas{3}, PadAreas{4}];
  
   % 89 99 172 155
    for j=1:415
        g1{j}='12';
        g2{j}='NoPods';
    end
    for j=416:830
        g1{j}='12';
        g2{j}='Pods';
    end
    for j=831:1245
        g1{j}='56';
        g2{j}='NoPods';
    end
    for j=1245:1660
        g1{j}='56';
        g2{j}='Pods';
    end
    
    figure(10)
[~,~,stats] = anovan(Mat2Stat,{g1, g2}, 'model','full','varnames',{'Rupture','Phenotype'})
AreaAnovaTable = multcompare(stats,'Dimension',[1 2])
PPPAnova=[AreaAnovaTable(2,6), AreaAnovaTable(5,6), AreaAnovaTable(1,6), AreaAnovaTable(6,6)];
figure(1); hold on;
ylim([0 460])
for j=1:4
    plot(LineSpots(j,:), [heights(j) heights(j)],'-k');
    text(mean(LineSpots(j,:)), heights(j)+5, SigStars(PPPAnova(j)));
end

   %% Quantify Depletion (Plot) 
% The two possible approaches are to take a non constant sdev to
% locate podosomes or to take a uniform regions surrounded identified
% podosome locations. I tried the second option and found it to be successful. 
% Although this is not perfect, it is a much easier metric, because thresholding faint podosomes is tricky,
% especially when some cells have more broad change in fluor under cell,
% which does not correspond w podosomal depletion.
close all
for jj=1:2
    Depletion{jj}=[]; Normal{jj}=[];
    for j=1:3
        for k=1:20
            if ~isempty(QuantDat{jj}{j,k})
                QuantDat{jj}{j,k}.Depletion=[];
                for l=1:length(QuantDat{jj}{j,k}.PodLoc)
                    QuantDat{jj}{j,k}.Mask{l}=zeros(512);
                    if QuantDat{jj}{j,k}.RTherePods~=1
                        QuantDat{jj}{j,k}.Depletion(l)=nan;
                    else
                        if isnan(QuantDat{jj}{j,k}.PodLoc{l})
                                QuantDat{jj}{j,k}.Depletion(l)=nan;
                                QuantDat{jj}{j,k}.Mask{l}=nan;
                        else
                            for pod=1:size(QuantDat{jj}{j,k}.PodLoc{l},1)
                        	podc=round(QuantDat{jj}{j,k}.PodLoc{l}(pod,2)); 
                            podr=round(QuantDat{jj}{j,k}.PodLoc{l}(pod,1)); 
                            QuantDat{jj}{j,k}.Mask{l}(podr,podc)=1;
                            end
                        QuantDat{jj}{j,k}.Mask{l}=imdilate(QuantDat{jj}{j,k}.Mask{l},strel('diamond',2));
                        QuantDat{jj}{j,k}.Mask{l}(QuantDat{jj}{j,k}.Mask{l}==0)=nan;
                        NormI=QuantDat{jj}{j,k}.Mask{l}.*QuantDat{jj}{j,k}.Fluor./QuantDat{jj}{j,k}.B{l};
                        Normal{jj}=[Normal{jj} mean(NormI(:),'omitnan')];
                        QuantDat{jj}{j,k}.Depletion(l)=100.*(1-mean(NormI(:),'omitnan'));
                        end
                    end
                end
            Depletion{jj}=[Depletion{jj} QuantDat{jj}{j,k}.Depletion];
            Depletion{jj}(Depletion{jj}<0)=nan;
            end
        end
    end
    MeanDep(jj)=mean(Depletion{jj},'omitnan');
    MedianDep(jj)=median(Depletion{jj},'omitnan');
    SDevsDep(jj)=std(Depletion{jj},'omitnan');
   
    %Plot on a scatter plot
end
close all
figure(89);
PaddedDep=PaddedBoxPlot(Depletion);
[hDep pDep]= ttest2(PaddedDep{:,1}, PaddedDep{:,2});
scatter([ones(1,length(PaddedDep{1})),ones(1,length(PaddedDep{1})).*2], [PaddedDep{:,1}, PaddedDep{:,2}],100, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.15);
xlim([0 3]);

hold on
for j=1:2
plot([j-.25 j+.25],[MeanDep(j) MeanDep(j)],'k');
end
plot([1 2], [48 48],'-k');

ylim([0 50]);
% Copy matricies and perform stats in GraphPad Prism

%
   %% Process the number of podosomes (Plot)
% How many podosomes are there in podosome-forming cells on 12 vs 56 pN
% stubstrates

for jj=1:2
    PodCount{jj}=[];
    for j=1:3
        for k=1:20
            if ~isempty(QuantDat{jj}{j,k})
                for l=1:length(QuantDat{jj}{j,k}.PodLoc)
                    if isnan(QuantDat{jj}{j,k}.PodLoc{l})
                        QuantDat{jj}{j,k}.PodCount(l)=nan;
                    else
                        QuantDat{jj}{j,k}.PodCount(l)=size(QuantDat{jj}{j,k}.PodLoc{l},1)
                    end
                end
            PodCount{jj}=[PodCount{jj} QuantDat{jj}{j,k}.PodCount];
            PodCount{jj}=PodCount{jj}(~isoutlier(PodCount{jj},'quartiles','ThresholdFactor',3));
      
            end
        end
    end
    MeanPods(jj)=mean(PodCount{jj},'omitnan');
    MedianPods(jj)=median(PodCount{jj},'omitnan');
    SDevsPods(jj)=std(PodCount{jj},'omitnan');
    MAXPods(jj)=max(PodCount{jj});
end

%Plot on a scatter plot
close all
figure(6);
PaddedPodN=PaddedBoxPlot(PodCount);


nn=length(PaddedPodN{1});
scatter([ones(1,nn),ones(1,nn).*2], [PaddedPodN{:,1}, PaddedPodN{:,2}],100, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.15);
xlim([0 3]);
pNumber=ranksum(PaddedPodN{1},PaddedPodN{2});
hold on
for j=1:2
plot([j-.25 j+.25],[MedianPods(j) MedianPods(j)],'k');
end
plot([1 2], [20 20],'-k');

ylim([0 35]);
% Copy vectors and perform statistics in GraphPad

