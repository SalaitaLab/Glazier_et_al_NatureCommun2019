function [fitresult, gof] = FitDData(X, Is)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%CREATEFIT(X,IS)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : X
%      Y Output: Is
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 26-Apr-2018 14:09:18


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( X, Is );

% Set up fittype and options.
ft = fittype( 'a*(1-exp(-x/T))+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0];
opts.Robust = 'Bisquare';
opts.StartPoint = [20 0 0.3];
opts.Upper = [100 1 0.5];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'Is vs. X', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel X
ylabel Is
grid on


