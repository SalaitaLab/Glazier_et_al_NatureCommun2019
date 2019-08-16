%% SET THRESHOLDING
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 

%% Read in the data and get the basic remaining vars. 

% Compile into one variable to easily loop through

load('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PodosomeAnalysis\1810Analysis\CutoffAnalysis181025\CutoffIms.mat');
ALLIMS={Ims_L, Ims_F, Ims_N};
for j=1:3
    for k=1:length(ALLIMS{j})
        cmapcut= ALLIMS{j}{k}.BAv_Cts + 1.3*ALLIMS{j}{k}.BDevs(1);
        ALLIMS{j}{k}.ClusterMap=bwareaopen(~imdilate(ALLIMS{j}{k}.Mask, strel('diamond',3)).*ALLIMS{j}{k}.Counts>cmapcut, 6);
        SD=ALLIMS{j}{k}.BAv_Cts+[-3.5*ALLIMS{j}{k}.BDevs 1.3*ALLIMS{j}{k}.BDevs];
        ALLIMS{j}{k}.BackgroundMap= bwmorph((ALLIMS{j}{k}.Counts<SD(2))& (ALLIMS{j}{k}.Counts>SD(1)),'close').*~ALLIMS{j}{k}.ClusterMap.*~ALLIMS{j}{k}.Mask;
        subplot(1,4,1); imshow(ALLIMS{j}{k}.Cts_PreCorr,[0 300]);
        subplot(1,4,2); imshow(ALLIMS{j}{k}.Mask); 
        subplot(1,4,3); imshow(ALLIMS{j}{k}.ClusterMap);
        subplot(1,4,4); imshow(ALLIMS{j}{k}.BackgroundMap);
       %pause(4);
    end
end
%% Build a giant list of photons to plot histograms
        % Pixels{SampleType,ImageSection}{Channel}
            % SampleType: 1. Lin 2. Four 3. Nineteen
            % ImageSelection: 1. Background 2. Clusters 3. Pods
            % Channels: 1. Counts 2. AvLife
           clear Pixels 
           close all
           
for j=1:3 %Lin, Four, Nineteen
    l=length(ALLIMS{j});
  %  Pixels{j}=cell{l};
    for k=1:length(ALLIMS{j})
        ALLIMS{j}{k}.BackgroundMap=double(ALLIMS{j}{k}.BackgroundMap);
        ALLIMS{j}{k}.ClusterMap=double(ALLIMS{j}{k}.ClusterMap);
        ALLIMS{j}{k}.Mask=double(ALLIMS{j}{k}.Mask);
        
        ALLIMS{j}{k}.BackgroundMap(ALLIMS{j}{k}.BackgroundMap==0)=nan;
        ALLIMS{j}{k}.ClusterMap(ALLIMS{j}{k}.ClusterMap==0)=nan;
        ALLIMS{j}{k}.Mask(ALLIMS{j}{k}.Mask==0)=nan;
        
        back=ALLIMS{j}{k}.BackgroundMap.*ALLIMS{j}{k}.Cts_PreCorr;
        backl=ALLIMS{j}{k}.BackgroundMap.*ALLIMS{j}{k}.AvLife;
        back_c=back(:); back_l=backl(:);
        
        clus=ALLIMS{j}{k}.ClusterMap.*ALLIMS{j}{k}.Cts_PreCorr;
        
        clus1=ALLIMS{j}{k}.ClusterMap.*ALLIMS{j}{k}.AvLife;
        clus_c=clus(:); clus_l=clus1(:);
        clus_c=clus_c(~isnan(clus_c));
        clus_l=clus_l(~isnan(clus_l));
        
        podo=ALLIMS{j}{k}.Mask.*ALLIMS{j}{k}.Cts_PreCorr;
        podo1=ALLIMS{j}{k}.Mask.*ALLIMS{j}{k}.AvLife;
        podo_c=podo(:); podo_l=podo1(:);
       
        if k==1 
            Pixels{j,1}{1}=back_c;
            Pixels{j,1}{2}=back_l;
            Pixels{j,2}{1}=clus_c;
            Pixels{j,2}{2}=clus_l;
            Pixels{j,3}{1}=podo_c;
            Pixels{j,3}{2}=podo_l;
        else
        %}
        Pixels{j,1}{1}=[Pixels{j,1}{1}; back_c];
        Pixels{j,1}{2}=[Pixels{j,1}{2}; back_l];
        Pixels{j,2}{1}=[Pixels{j,2}{1}; clus_c];
        Pixels{j,2}{2}=[Pixels{j,2}{2}; clus_l];
        Pixels{j,3}{1}=[Pixels{j,3}{1}; podo_c];
        Pixels{j,3}{2}=[Pixels{j,3}{2}; podo_l];
       
        end
        for r=1:3
            for l=1:2
            Pixels{j,r}{l}=Pixels{j,r}{l}(~isnan(Pixels{j,r}{l}));
            end
        end
    end
    disp('hello')
end
%% Plot Histograms
close all
Edge_Cts=0:10:250;
Edge_Life=[0:.1:3].*10^-9;
NameGraph={'Background','Clusters','Podosomes'};
colo={'r','g','b'}

%For indiv plots
T={'Linear','4.7 pN','19 pN'};
for j=1:3
    
    subplot(2,3,j); 
   
    histogram(Pixels{j,1}{1},Edge_Cts, 'Normalization','probability','FaceColor','r');
    hold on
    histogram(Pixels{j,2}{1},Edge_Cts, 'Normalization','probability','FaceColor','g');
    histogram(Pixels{j,3}{1},Edge_Cts, 'Normalization','probability','FaceColor','b');
    title(T{j},'FontWeight','Bold');
    ylabel('Frequency');
    xlabel('Photon Counts');
    
    
    set(gca, 'FontName','Arial','FontSize',18);
    ylim([0 .32])
   subplot(2,3,j+3); 
  
    histogram(Pixels{j,1}{2}.*10^9,Edge_Life.*10^9, 'Normalization','probability','FaceColor','r');
    hold on
    histogram(Pixels{j,2}{2}.*10^9,Edge_Life.*10^9, 'Normalization','probability','FaceColor','g');
    histogram(Pixels{j,3}{2}.*10^9,Edge_Life.*10^9, 'Normalization','probability','FaceColor','b');
    title(T{j},'FontWeight','Bold');
    ylabel('Frequency');
    xlabel('Av. Lifetime (ns)');
    set(gca, 'FontName','Arial','FontSize',18);
    
    ylim([0 .32])
    xlim([0 5])
end
    
 
if j==3
        legend(NameGraph,'FontSize',14,'FontName','Arial');
        legend('boxoff');
    end
%}


%% Examine pixels per category - Note included in paper SI but an interesting way to visualize. 
close all
for j=1:3
T={'Linear','4.7 pN','19 pN'};
  figure(j); 
   
    scatter( Pixels{j,1}{1},Pixels{j,1}{2}.*10^9,'.r');
    ylim([0 10]);
    xlim([0 275])
    hold on
plot([0 275],[3.26 3.26],'r','LineWidth',1);
    
    plot([0 275],[2.97 2.97],'r--','LineWidth',1);
       plot([25 25], [0 10],'k','LineWidth',1);
    xlabel('Counts'); ylabel('Av. Lifetime (ns)');
    set(gca, 'FontName','Arial','FontSize',18);
    title(T{j},'FontWeight','Bold');
    
    figure(j); 
    scatter( Pixels{j,2}{1},Pixels{j,2}{2}.*10^9,'.g');
   plot([0 275],[3.26 3.26],'r','LineWidth',1);
   
    plot([0 275],[2.97 2.97],'r--','LineWidth',1);
      plot([25 25], [0 10],'k','LineWidth',1);
    ylim([0 10]);
    xlim([0 700])
    hold on
    
   title(T{j},'FontWeight','Bold');
    xlabel('Counts'); ylabel('Av. Lifetime (ns)');
    set(gca, 'FontName','Arial','FontSize',18);
    
      figure(j); 
   
    scatter( Pixels{j,3}{1},Pixels{j,3}{2}.*10^9,'.b');
    ylim([0 10]);
    xlim([0 275])
    hold on
    plot([0 275],[3.26 3.26],'r','LineWidth',1);
    
    plot([0 275],[2.97 2.97],'r--','LineWidth',1);
     plot([25 25], [0 10],'k','LineWidth',1);
    xlabel('Counts'); ylabel('Av. Lifetime (ns)');
    set(gca, 'FontName','Arial','FontSize',18);
    title(T{j},'FontWeight','Bold');
axis square
end
%% How do different photon counts contribute? STATISTICS

for j= 1:3
    for k=1:3
            ind1sd=find(Pixels{j,k}{2}>2.97.*10^-9);
            ind2sd=find(Pixels{j,k}{2}>3.25.*10^-9);
            NonsenseData1sd{j,k}=Pixels{j,k}{1}(ind1sd);
            NonsenseData2sd{j,k}=Pixels{j,k}{1}(ind2sd);
            if isempty(NonsenseData1sd{j,k})
                NonsenseData1sd{j,k}=nan;
            else
            NonsenseData1sd_MC(j,k)=mean(NonsenseData1sd{j,k},'omitnan');
        NonsenseData1sd_MCstd(j,k)=std(NonsenseData1sd{j,k},'omitnan');
         
            end
            if isempty(NonsenseData2sd{j,k})
                NonsenseData2sd{j,k}=nan;
            else
                NonsenseData2sd_MC(j,k)=mean(NonsenseData2sd{j,k},'omitnan');
        NonsenseData2sd_MCstd(j,k)=std(NonsenseData2sd{j,k},'omitnan');
            end
    end
end

% This is about 25 photons w hich is equivalent to S/N = 5. I will set this
% as my threshold. I will also exclude photons higher than 1SD, which is
% 2.97 photons. This is also reasonable given the average lifetime of Cy3B
% around 2.3-2.6 depending on report/measurement. Any pix w higher that
% aren't caused by low photon counts could have some other junk. It's
% probably unlikely to be caused by probes. 

