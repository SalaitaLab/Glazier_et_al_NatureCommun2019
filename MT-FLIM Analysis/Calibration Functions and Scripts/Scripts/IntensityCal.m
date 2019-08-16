%% Intensity Cal
% Determine quenching efficiency. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Gather Data

Four='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\ICalDataTogether\Four';
Nineteen='C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\ICalDataTogether\Nineteen';
PO={'0','4','10','20','40','60','80','100'};
X=[0 4 10 20 40 60 80 100];
for j=1:8
[RawData19{j}, MeanMatrix19{j}, DevMatrix19{j},LookAt{19}]=PercOpen_Intensity(fullfile(Nineteen, PO{j}));
[RawData4{j}, MeanMatrix4{j}, DevMatrix4{j},LookAt4{j}]=PercOpen_Intensity(fullfile(Four, PO{j}));
MeanI19(j)=mean(MeanMatrix19{1,j},'omitnan');
MeanI4(j)=mean(MeanMatrix4{1,j},'omitnan');
SEMI4(j)=SEM_calc(MeanMatrix4{1,j});
SEMI19(j)=SEM_calc(MeanMatrix19{1,j});
end
close all
figure(2);
scatter(X,MeanI4,'or'); hold on;
scatter(X,MeanI19,'ob'); hold on;
for j=1:8
errorbar(X(j), MeanI19(j), SEMI19(j),'b');
errorbar(X(j), MeanI4(j), SEMI4(j),'r');
end
FP19=LinearFit_Plot(X,MeanI19,'b'); FP4=LinearFit_Plot(X, MeanI4,'r');
Q19=QEFIT(FP19); Q4=QEFIT(FP4);
ylim([0 4500]);
legend('Four pN','Nineteen pN');
title('Fluorescent Intensity');
ylabel('Fluorescent Intensity (A.U.)');
xlabel('Percent Open');
% Because the probe intensity is not significantly different between 19, 4
% pN probes I will use average of entire data set. 
%}
close all
figure(5);
hold on
for j=1:8
    TotalMean(j)=mean([MeanMatrix19{j}, MeanMatrix4{j}]);
    TotalSEM(j)=SEM_calc([MeanMatrix19{j}, MeanMatrix4{j}]);
    errorbar(X(j), TotalMean(j), TotalSEM(j), 'b');
end
scatter(X, TotalMean,'ob');
[r c]=ginput(1);
r=round(r); c=round(c);
text(r,c,'Quenching Efficiency = 78%');

title('Fluorescence Intensity vs Percent Open');
xlabel('Percent Open');
ylabel('Fluorescence Intensity (A.U.)');
xlim([0 100]);
ylim([0 4500]);
[FP overallrsq]=LinearFit_Plot(X,TotalMean,'b'); 
QE=QEFIT(FP);


