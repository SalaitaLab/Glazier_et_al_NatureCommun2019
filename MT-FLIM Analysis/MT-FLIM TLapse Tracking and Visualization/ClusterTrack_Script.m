%% This script is used in conjunction with TrackMate in FIJI to track receptor clusters that are not podosome associated. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%% Bring in data from before with individual cells and podosome tracking.
clear

DataSet= 'C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\Tlapse_0817\2017_08\Tlapse2';
[ICells] = Cells2Track(DataSet);

% Select cell that you woud like to track
CellN= 1;
indivcells=ICells{CellN};

%% Cluster Mask Making
% This will save a tiffstack to analyze (without branching, merging, or
% splitting) using TrackMate in FIJI. 

% When prompted with an image, select a background region in the corner. 

ClusterFinder(indivcells, 'SampleTifStack.tif')

%% Outside MATLAB STEP: Process your tifstack of the clusters in FIJI Using TrackMate. 
% No branching, no merging, no splitting

%% Plot Cluster Tracks
ClusterTrackPlotter('C:\Users\roxgl\OneDrive - Emory University\Salaita Lab\Data\PodosomePaper_ReviseResubmitNewData\TlapseAnalyzeClusters\TRACKIDS_nomergeorsplit_wtimes.xlsx',indivcells, 0.08);
