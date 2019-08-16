% This script can be used to track podosomes from clustering/ formation. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Read Data and select cell
DataSet= 'C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\Tlapse_0817\2018_10';
[ICells] = Cells2Track(DataSet);

% Select cell that you woud like to track
CellN= 1;

%% Track Pods;

% For podosome tracking we tried several more automated strategies, but
% none could beat manual due to the biological complexity of the data (dark
% and bright regions, clusters turning into podosomes, different emergence
% times, splitting, merging, etc.). The strategy we came up with is to
% track the podosome backwards. Start with the last frame and go back to
% the origin of the podosome. If the trajectory has ended then hit enter to
% proceed onto the next. This function will allow you to perform this
% manual tracking with an output of individual tracks. 
[c r] = TrackPods(ICells{CellN});


%% Plot tracks

% This will plot your trajectory on top of the final image (Photon Counts),
% with a 3 micron scale bar. 

% To plot with a white background, you can comment out line 18 and uncomment line 19.  
PlotTrack(c,r, 0.14, ICells{1});

%% Make beautiful Kymographs

% Create FLIM Mask for "noisy" pixels
Masking = KymoMasking(ICells{1});
% Create Custom Kymographs
close all;
KymoBoxLapse(ICells{1},Masking);
  

