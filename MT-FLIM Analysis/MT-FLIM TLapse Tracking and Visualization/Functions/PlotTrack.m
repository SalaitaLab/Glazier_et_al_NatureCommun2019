function [] = PlotTrack(c, r, PixSz, ICells)
%This function is used to plot tracks for podosomes and clusters. 
% Input is the column and row cell arrays that are the output of TrackPods.
% Additional input is the pixel size. The final input is your cell array of
% individual cells. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
par= parula;
TPts= length(c);
if TPts > (length(par)/2)
    error('For a time series of this length you must adjust the color mapping in this function');
else
    CCC= cell2mat(c); RRR= cell2mat(r);
    CNan= ~isnan(RRR);
    SZ= size(CCC);
    podN= SZ(1); 
close all; 
hold on;
imshow(ICells{TPts, 1},[]); 
%set(gcf,'color','w');
hold on
for j=1:TPts
    if j<TPts
    for k=1:podN
        plot([c{k,j} c{k,j+1}], [r{k,j} r{k,j+1}],'-', 'MarkerSize',12, 'color',par(j*2,:),'LineWidth',2);
        hold on
    
    if j== min(find(~isnan(CCC(k,:)))) 
           plot(c{k,j}, r{k,j},'.k','MarkerSize',16,'color',par(j*2,:));
    end
    end
    if j==1
        plot(c{k,j}, r{k,j},'.k', 'MarkerSize',16, 'color',par(j*2,:));
    end
    end
end
axis square
box off
axis off
 
ScaleBarBlack(ICells{1,1},PixSz, 3)

end

