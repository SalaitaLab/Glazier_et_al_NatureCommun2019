%% This script can be used to process your MT-FLIM data. 
% We include a sample image each for Linear, 4.7 pN, and 19 pN images.
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Load important variables

load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FLIMIlluminationData.mat', 'IllumProfz5');
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips\FixedCalVars.mat','CustomLUT');
load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PodosomeAnalysis\1801cutoffcorrection\CutoffVars190127.mat');
%% Four pN

close all
clc

FNa='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips';
Cond='Four', FNc='FourCells2Analyze'; 
FN= fullfile(FNa, Cond, FNc); P=CustomLUT{1,2}; IllumProf=IllumProfz5;
FileList=FindFiles(FN,'*.tif'); COFF=25 %Sets photon count cutoff

FourVars={};
for j=1:2 % length(FileList)
    CVars=MTFLIMFunction(FileList{j}, P, IllumProf, Cond, 2.97*10^-9, 25);
    DummyMat4= {FourVars, CVars};
    FourVars=cat(2,DummyMat4{:});
end

%% Nineteen pN

close all
clc

FNa='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips';
Cond='Nineteen', FNc='NineteenCells2Analyze'; 


FN= fullfile(FNa, Cond, FNc); P=CustomLUT{2,2}; IllumProf=IllumProfz5;
FileList=FindFiles(FN,'*.tif'); COFF=25 %Sets photon count cutoff

NineteenVars={};
for j=1:length(FileList)
    CVars=MTFLIMFunction(FileList{j}, P, IllumProf, Cond, 2.97*10^-9, 25);
    DummyMat19= {NineteenVars, CVars};
    NineteenVars=cat(2,DummyMat19{:});
end

%% Linear

close all
clc

FNa='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips';
Cond='Lin', FNc='LinCells2Analyze'; 


FN= fullfile(FNa, Cond, FNc); %{ We won't use the custom LUT here but the code skips over it anyways. However, we still need to define it for the function.%} 
P=CustomLUT{2,2}; IllumProf=IllumProfz5;
FileList=FindFiles(FN,'*.tif'); COFF=25 %Sets photon count cutoff

LinVars={};
for j=1:2 %length(FileList)
    CVars=MTFLIMFunction(FileList{j}, P, IllumProf, Cond, 2.97*10^-9, 25);
    DummyMatLin= {LinVars, CVars};
   	LinVars=cat(2,DummyMatLin{:});
end

%% Quatify and Plot Data
close all
% Compile variables
BigVar ={LinVars, FourVars, NineteenVars};

% Define Vars
PodAvs ={}; AvTauSLB={}; MeanPercent={}; d=1;

% Perform statistics on the cell level
for j=1:3 % Conditions
    for k=1:length(BigVar{j})
         PodAvs{j}(d,1)=BigVar{j}{k}.PodAvs;
        AvTauSLB{j}(k)=BigVar{j}{k}.BAv_Life;
       
       % if j~=1
            MeanPercent{j}(d,1)=BigVar{j}{k}.MeanPercent;
        %end
        d=d+1;
    end
    d=1;
end

% Plot average lifetime
figure(10);
PodAvs=PaddedBoxPlot2(PodAvs);  
MeanPercent=PaddedBoxPlot2(MeanPercent);
MP=[mean(MeanPercent{1,2},'omitnan'); mean(MeanPercent{1,3},'omitnan')];
MedianP=[median(MeanPercent{1,2},'omitnan'); median(MeanPercent{1,3},'omitnan')];
PodAvTau=[PodAvs{1}, PodAvs{2}, PodAvs{3}];
PodoAvLife=mean(PodAvTau,1,'omitnan');
BackgroundAvTau=[mean(AvTauSLB{1}),mean(AvTauSLB{2}), mean(AvTauSLB{3})];
[p_perc,h_perc,stats_perc] = ranksum(cell2mat(MeanPercent(:,2)), cell2mat(MeanPercent(:,3)));
p_life = kruskalwallis(PodAvTau);


X= [ones(1,length(PodAvs{1})), ones(1,length(PodAvs{1})).*2, ones(1,length(PodAvs{1})).*3];
scatter(X, [PodAvs{:,2};PodAvs{:,3}; PodAvs{:,1} ]',150, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.15);
ylim([.75 2.2].*10^-9);
xlim([0 4]);
ylim([0 2.4].*10^-9);
xticks([1 2 3])
xticklabels({'4 pN','19 pN','Lin'})
set(gca,'FontSize',14,'FontName','Arial')
ylabel('Average Fluorscence Lifetime (ns)','FontSize',14,'FontName','Arial');
hold on;
plot([1 3],[2.1 2.1].*10^-9,'-k');
text(2,2.12e-9,SigStars(p_life),'HorizontalAlignment','center','FontSize',12,'FontName','Arial','LineWidth',1);
ord=[2 3 1];
for j=1:3
plot([j-.2 j+.2],[PodoAvLife(ord(j)) PodoAvLife(ord(j))],'r');
plot([j-.2 j+.2], [BackgroundAvTau(ord(j)) BackgroundAvTau(ord(j))],'Color',[.3 .3 .3],'LineStyle','--');
PodoAvLife(ord(j)) 
end

% Plot percent open
figure(20);
scatter([ones(length(MeanPercent{1}),1);ones(length(MeanPercent{1}),1).*2], [MeanPercent{:,2}; MeanPercent{:,3}]',150, '.','MarkerFaceColor',[0.1764    0.5499    0.9520],'jitter','on', 'jitterAmount', 0.15);
xlim([0 3]);
ylim([0 25]);
xticks([1 2])
xticklabels({'4 pN','19 pN'})
set(gca,'FontSize',14,'FontName','Arial')
ylabel('Open Probes (%)','FontSize',14,'FontName','Arial');
hold on;
plot([1 2],[23 23],'-k');
text(1.5,23.5,SigStars(p_perc),'HorizontalAlignment','center','FontSize',12,'FontName','Arial','LineWidth',1);
