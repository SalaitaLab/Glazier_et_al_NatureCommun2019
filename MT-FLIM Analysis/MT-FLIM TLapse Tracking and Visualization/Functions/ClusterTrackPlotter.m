function [] = ClusterTrackPlotter(FileAddress, CellIm,PixSz)
% Input is the file address containing the excel spreadsheet exported from
% TrackMat. In addition, for the Scale Bar, you will need to input the cell
% stack that you used to generate the masks, along w the pixel size.
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
close all

clear ClustTrackDat Clust_TD Track
% Load data
Clust_TD=xlsread(FileAddress);
% Sort by TRACK ID
ClustTrackDat=Clust_TD;
ClustTrackDat=sortrows(Clust_TD,2);
% Correct indexes to be compatible w matlab
ClustTrackDat(:,2)=ClustTrackDat(:,2)+1;
ClustTrackDat(:,5)=ClustTrackDat(:,5)+1;

% Label single points
for j=1:length(ClustTrackDat)
    if isnan(ClustTrackDat(j,2))
        MaxTrack=max(ClustTrackDat(:,2));
        ClustTrackDat(j,2)=MaxTrack+1;
    end
end

% Generate cell array w Tracks
for Tr=1:max(ClustTrackDat(:,2))
    Ind=find(ClustTrackDat(:,2)==Tr);
    ClusterTracks{Tr}=ClustTrackDat(Ind,:);
end

% Plot
Col=parula;
figure(1);
set(gcf,'color','w');
 hold on
axis square
box off
axis off
for j=1:Tr
    Sz=size(ClusterTracks{j});
 % Get time point indexes
        tpt=unique(ClusterTracks{j}(:,4));
        if length(tpt)==Sz(1)
            for t=1:(Sz(1)-1)
                X1=ClusterTracks{j}(t,3); X2= ClusterTracks{j}(t+1,3);
                Y1=ClusterTracks{j}(t,4); Y2= ClusterTracks{j}(t+1,4);
                Colo=2*ClusterTracks{j}(t+1,5);
                plot([X1 X2],[Y1 Y2],'-','Color',Col(Colo,:),'LineWidth',3);
            end
            plot(ClusterTracks{j}(1,3), ClusterTracks{j}(1,4),'.','MarkerSize',12,'color',Col(ClusterTracks{j}(1,5)*2,:));
           
        end
end
hold on
ScaleBarBlack(CellIm{1,1},PixSz, 5)

end

