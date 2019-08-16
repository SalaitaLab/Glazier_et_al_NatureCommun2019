function [Radii_Microns, MedLine, MeanLine] = RadiusProc(BeforeAfterData, PixelSz)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This is used for drug data. The input is a 2 x N (cells) cell array of
%PodImage2's. This variable is generated with the MTFLIM Drug Analysis
%function. Output is a cell array with radii for before and after treatment, along with the means and medians (outliers excluded) of these samples. The additional input
%is your imaging pixel size in microns. 
for t=1:2
    Radii{t}=[];
    for c=1:length(BeforeAfterData)
        PodAvs(t,c)= BeforeAfterData{t,c}.PodAvs;
        MeanPercent(t,c)= BeforeAfterData{t,c}.MeanPercent;
        Props{t,c}=BeforeAfterData{t,c}.Props;
        D{t,c}= mean([Props{t,c}.MajorAxisLength Props{t,c}.MinorAxisLength],2);
        R{t,c}= D{t,c}/2;
        % Only 'round-ish' podosomes are considered. This filters out
        % podosome multiples that did not isolate during thresholding.
        Cir{t,c}= Props{t,c}.Eccentricity<=.7;
        Cir{t,c}= double(Cir{t,c});
        Cir{t,c}(Cir{t,c}==0)=nan;
        % Radius statistics are performed over the population rather than
        % on a cell basis, because otherwise cells may be compared with
        % completely different podosomes meeting the circularity and
        % thresholding analysis before and after drug treatment, so the
        % comparisons would not always be meaningful. This allows us to
        % look at the overall population trend. 
        Radii{t}=[Radii{t}; Cir{t,c}.*R{t,c}];
    end
        Radii_Microns{t}= Radii{t}.*PixelSz;
        % Remove outliers
        Radii_Microns{t}=Radii_Microns{t}(~isoutlier(Radii_Microns{t}));
        MedLine(t) = median(Radii_Microns{t},'omitnan');
        MeanLine(t)= mean(Radii_Microns{t},'omitnan');
end

