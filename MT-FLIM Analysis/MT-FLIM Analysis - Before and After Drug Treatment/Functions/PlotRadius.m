function [] = PlotRadius(Radii, MeanOrMed)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is 1x 2 cell array of podosome radii and either the median line or
%the mean line, depending on your data normality. 
%   
close all;
for t=1:2
    scatter(t.*ones(1, length(Radii{t})), Radii{t},'.', 'MarkerFaceColor','b','jitter','on', 'jitterAmount', 0.15);
    hold on
    plot([t-0.2 t+0.2], [MeanOrMed(t) MeanOrMed(t)],'-r');
end
plot([1 2],[.75 .75]);
xlim([0 3]);
ylim([0 0.8]);
ylabel('Radius (microns)');
xticks([1 2]); xticklabels({'Before','After'});
end

