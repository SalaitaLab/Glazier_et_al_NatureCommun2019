% This code is intended to take FLIM histograms and turn them into a
% calibration curve for MT-FLIM analysis. Histograms were generated in
% SymPhoTime 64 as described in Glazier, et. al. 2019.
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Read and fit data to a single gaussian

% 3 replicates per condition (see exceptions below). Store data in a large
% folder with teh subfolders as below. Data will load in the order of X.

BigFolder= 'C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\RoxyExport1minClips';
SubFolders= {'FourCal_z3','FourCal_z5'; 'NineteenCal_z3','NineteenCal_z5'};
Rep={'Rep1','Rep2','Rep3'};
X=[0 100 10 20 40 4 60 80]
for j=1:2
    for k=1:2
        for l=1:3
            
            FN=fullfile(BigFolder, SubFolders{j,k},Rep{l})
            
            % Load replicates for each condition and fit to a single
            % gausssian. 
            [MeanTau{j,k}{l}, HistoCell{j,k}{l}, GFit{j,k}{l}]=ProcessPercOpen(FN);
            
            % I am missing a technical replicate for 1 condition and a
            % measurement  for a second. Put in NANs so not to mess up
            % calculations. 
            if j==1 && l==2
                MeanTau{j,k}{l}=[MeanTau{j,k}{l}(1:2,:); [nan nan nan]; MeanTau{j,k}{l}(3:7,:)];
                HistoCell{j,k}{l}=[HistoCell{j,k}{l}(1:2,:); {nan nan nan}; HistoCell{j,k}{l}(3:7,:)];
                GFit{j,k}{l}=[GFit{j,k}{l}(1:2,:); {nan nan nan}; GFit{j,k}{l}(3:7,:)];
            end
            if j==1 && k==2 && l==3
                MeanTau{j,k}{l}=[MeanTau{j,k}{l}(1:5,:); [nan nan nan]; MeanTau{j,k}{l}(6:7,:)];
                HistoCell{j,k}{l}=[HistoCell{j,k}{l}(1:5,:); {nan, nan, nan}; HistoCell{j,k}{l}(6:7,:)];
                GFit{j,k}{l}=[GFit{j,k}{l}(1:5,:); {nan nan nan}; GFit{j,k}{l}(6:7,:)];
            end
        end
    end
end
%% Generate LUTs
close all
X=[0 100 10 20 40 4 60 80]
ct=1; TITLE={'4 pN - z3','4 pN - z5','19 pN - z3','19 pN - z5'};

% We weren't sure if the pixel dwell of our imaging would affect the
% calibration (it is possible DNA could be partly melted - it was not) so
% we performed these calcs with z3 = pharmacological inhibitor image zoom
% and z5 = fig 2 zoom. 

% Take the average center of the gaussian for each data point and use this
% to generate a plot of % open versus average fluroescence lifetime. 
% Curve fit these data to a biexponential.
% Generate an LUT with 5% intervals from the biexponential fit. 
for j=1:2
    for k=1:2
        
        for l=1:3
            MT{j,k}(:,l)=mean(MeanTau{j,k}{1,l},2,'omitnan');
            hold on
            figure(ct); 
        scatter(X,MT{j,k}(:,l));
        end
        
            AvLife{j,k}=mean(MT{j,k},2,'omitnan');
            for n=1:8
            StandardErr{j,k}(n,1)=SEM_calc(MT{j,k}(n,:));
            end
         figure(10 *ct); hold on
         scatter(X, AvLife{j,k},'o');
         errorbar(X, AvLife{j,k}, StandardErr{j,k},'LineStyle','none');
         xlim([0 100]); 
         title(TITLE{ct});
        
        [FitVals{j,k}, gof{j,k}, ci{j,k}] = createFitPercO(X, AvLife{j,k});
        %}
        CustomLUT{j,k}=CalLUTMaker(FitVals{j,k});
        
        ct=ct+1;
    end
end
%% Run statistics for Revisions to determine which data points are statistically significantly different

% In revision, we were asked to see which data points were statistically
% significantly different. These are indicated in Figure 2. This section of
% code will perform those statistics. Note that these data are based on
% means used for curve fitting. This analysis does not consider the
% histogram variance, which is a function of photon counts per pixel. I
% attempted to hold the total photon count rate relatively constant, but
% open probes will always generate more photons. 
close all
clear cRevStats StarChart
for j=1:2
    for k=1:2
        Mat2An=MT{j,k}';
        [pRevStats{j,k} tRevStats{j,k} sRevStats{j,k}]=anova1(Mat2An);
        cRevStats{j,k} = multcompare(sRevStats{j,k});
        
    end
end
    
for j=1:2
   for k=1:2
       l=1;
  % Prep to export to source data file and to add sig stars to plot
          % in illustrator
      for col=1:2
         cRevStats{j,k}(:,col)=X(cRevStats{j,k}(:,col));
      end
        cRevStats{j,k}=num2cell(cRevStats{j,k});
      for r=1:28
        cRevStats{j,k}{r,7}=SigStars(cRevStats{j,k}{r,6}(1,1));
        % Make my life easy to read this and add lines and stars in illustrator since I
        % already had figure generated. 
        if strcmp(cRevStats{j,k}{r,7},'****')~=1
            for sp=1:7
            StarChart{j,k}{l,sp}=cRevStats{j,k}{r,sp};
            end
            l=l+1;
        end
      end
   end
end
%% Generate various plots

close all
xx=[1:100];
NameMe={'(0.08 microns/pixel)','(0.13 microns/pixel)'}; C={'b','r'};

%
for j=1:2
figure(j)
hold on;
for k=1:2
    
h{k}=scatter(X,AvLife{k,j},'.',C{k});

errorbar(X,AvLife{k,j},StandardErr{j,k},'LineStyle','none','Color',C{k});
a=FitVals{k,j}.a; b=FitVals{k,j}.b; c=FitVals{k,j}.c; d=FitVals{k,j}.d;
plot(a.*exp(xx.*b)+c.*exp(xx.*d),'--','Color',C{k});
ylim([0 4]);
xlim([0 100]);
title(strcat('Average Fluorescence Lifetime',{' '},NameMe{j}),'FontName','Arial','FontSize',14,'FontWeight','bold');
xlabel('Percent Open','FontName','Arial','FontSize',14);
ylabel('Cy3B Average Lifetime (ns)','FontName','Arial','FontSize',14);
end
legend([h{1},h{2}],{'4 pN','19 pN'},'FontName','Arial','FontSize',12)
legend boxoff
end
set(gca,'FontName','Arial','FontSize',14);
par=parula;
ord=[1 6 3 4 5 7 8 2]
colorj={'r','r','g','b','c','m','k','y'}
for jj=1:8
    jjj=ord(jj)
    figure(18); 
    hold on;
    plot(HistoCell{1,1}{1,1}{jjj,1}(:,1), HistoCell{1,1}{1,1}{jjj,1}(:,2),'color',colorj{jjj},'linewidth',1);
figure(19); hold on;
m=max(HistoCell{1,1}{1,1}{jjj,1}(:,2));
 plot(HistoCell{1,1}{1,1}{jjj,1}(:,1),double(HistoCell{1,1}{1,1}{jjj,1}(:,2))./m,'color',par(jj*7,:),'linewidth',2);
end
figure(19)
xlim([0 4]);
ylim([0 1]);
title('Representative Average Lifetime Histograms','FontName','Arial','FontSize',14);
xlabel('Average Lifetime (ns)');
ylabel('Counts (normalized)');
legend('0','4','10','20','40','60','80','100');
legend('boxoff')
xlabel('Percent Open','FontName','Arial','FontSize',14);
figure(18);
xlim([0 4])
title('Average Lifetime Histogram Data');
xlabel('Average Lifetime (ns)');
set(gca,'FontName','Arial','FontSize',14);
%}

ylabel('Counts');
legend('0','4','10','20','40','60','80','100');
legend('boxoff')
set(gca,'FontName','Arial','FontSize',14);
figure(20);
ord=[1 6 3 4 5 7 8 2]
hold on
for j=1:8
    jj=ord(j);
    for k=1:2
    tofindSD=GFit{k,1}{1,1}{jj,1}.c1;
    mean=GFit{k,1}{1,1}{jj,1}.b1;
    SD2(jj)=sqrt(tofindSD/2);
    SD(jj)=sqrt(tofindSD/2);
    scatter(X(jj),mean,'ok');
    if k==1
    plot([X(jj)-.3 X(jj)-.3], [mean-SD(jj) mean+SD(jj)],'b','LineWidth',1);
    scatter(X(jj),mean,'ob');
    else 
    plot([X(jj)+.3 X(jj)+.3], [mean-SD(jj) mean+SD(jj)],'r','LineWidth',1);
    scatter(X(jj),mean,'or');
    end
    end
end
title('Representative Histogram Data w/ Error Bars Representing 1 SD');
ylabel('Average Lifetime (ns)');
xlabel('Percent Open');
set(gca,'FontName','Arial','FontSize',14);
    
ord=[1 8 3 4 5 2 6 7]
hold on
for j=1:8
    jj=ord(j);
    for k=1:2
    tofindSD=GFit{k,1}{1,1}{jj,1}.c1;
    mean=GFit{k,1}{1,1}{jj,1}.b1;
    SD2(jj)=sqrt(tofindSD/2);
    scatter(X(jj),mean,'ok');
    if k==1
    plot([X(jj)-.3 X(jj)-.3], [mean-SD(jj) mean+SD(jj)],'b','LineWidth',2);
    scatter(X(jj),mean,'ob');
    else 
    plot([X(jj)+.3 X(jj)+.3], [mean-SD(jj) mean+SD(jj)],'r','LineWidth',2);
    scatter(X(jj),mean,'or');
    end
    end
end
title('Representative Histogram Data w/ Error Bars Representing 1 SD');
ylabel('Average Lifetime (ns)');
xlabel('Percent Open');
set(gca,'FontName','Arial','FontSize',14);
%% Plot 19 av lifetime representative histograms
close all
par=parula;

ord=[1 6 3 4 5 7 8 2]
colorj={'r','r','g','b','c','m','k','y'}
for jj=1:8
    jjj=ord(jj)
    figure(18); 
    hold on;
    plot(HistoCell{2,1}{1,1}{jjj,3}(:,1), HistoCell{2,1}{1,1}{jjj,3}(:,2),'color',colorj{jjj},'linewidth',1);
figure(19); hold on;
m=max(HistoCell{2,1}{1,1}{jjj,1}(:,2));
 plot(HistoCell{2,1}{1,1}{jjj,1}(:,1),double(HistoCell{2,1}{1,1}{jjj,1}(:,2))./m,'color',par(jj*7,:),'linewidth',2);
end
figure(19)
xlim([0 4]);
ylim([0 1]);
title('Representative Average Lifetime Histograms','FontName','Arial','FontSize',14);
xlabel('Average Lifetime (ns)');
ylabel('Counts (normalized)');
legend('0','4','10','20','40','60','80','100');
legend('boxoff')
xlabel('Percent Open','FontName','Arial','FontSize',14);
figure(18);
xlim([0 4])
title('Average Lifetime Histogram Data');
xlabel('Average Lifetime (ns)');
set(gca,'FontName','Arial','FontSize',14);
%}
