function [QE] = QEFIT(fitparams)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
% Calculate quenching efficiency from a linear regression. 
zero=fitparams(1)*0+fitparams(2);
hundred=fitparams(1)*100+fitparams(2);

QE= (hundred-zero)/hundred;
end

