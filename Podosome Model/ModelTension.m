%% Evaluating Force Balance

% This code is used to model the podosome protrusive forces in Figure 7. 

DOPCFootprint= .72*(10^-9)^2;
LipidsPerMicron= (1*(10^-6)^2)./DOPCFootprint; %1 leaflet
BiotinLipidsPerMicron= .001*LipidsPerMicron;

% Plot Force

ProbesPerMicron= [.5 1 2].*BiotinLipidsPerMicron 
Force=[0 20 30 40 50 60].*10^-12; % Force per Probe
CoreR= 0.3 %microns
A_Apply= pi.*(1-.3^2);

for j=1:3
F4(j)=A_Apply.*.14.*ProbesPerMicron(j)*4.7*10^-12*10^9;
F19(j)=A_Apply.*.11.*ProbesPerMicron(j)*19*10^-12*10^9;
Dist(j)=A_Apply.*ProbesPerMicron(j).*(4.7*.03+19*.11)*10^-12*10^9;
end
neg4=F4(2)-F4(1); pos4=F4(3)-F4(2);
neg19=F19(2)-F19(1); pos19=F19(3)-F19(2);
negd=Dist(2)-Dist(1); posd=Dist(3)-Dist(2);
for j=1:length(ProbesPerMicron)
    for k=1:length(Force)
Ftot(j,k)= A_Apply.*.10.*ProbesPerMicron(j)*Force(k)*10^9;
    end
end

close all
    errorbar(4.7, F4(2),neg4, pos4,'ok');
    hold on
    errorbar(19, F19(2), neg19, pos19,'ok');
    plot(10^12.*Force(:),Ftot(2,:),'-');
    hold on
    plot(10^12.*Force(:), Ftot(1,:),'-');
    plot(10^12.*Force(:), Ftot(3,:),'-');
  errorbar(15.93, Dist(2), negd, posd,'or');

ylim([0 50])
xlim([0 50])
ylabel('Net Integrin Force (nN)');
xlabel('pN per Integrin');
