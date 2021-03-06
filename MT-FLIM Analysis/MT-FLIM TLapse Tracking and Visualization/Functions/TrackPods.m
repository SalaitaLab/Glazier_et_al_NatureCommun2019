function [col rrow] = TrackPods(ICell)
%This function is used to track podosomes. The input is the individual cell
%stack generated by Cells2Track. % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%   Output is

% Find total frames
time = length(ICell); TF= time;
% Create Cell Array to store data points
col={}; rrow={};
SZ=size(col);

% Fill in empty cells with nan. These are points which this podosome

track=1;
while track == 1
    
Ct= size(col); spot= Ct(1) + 1;
for jj=1:time
    col{spot,jj}=nan;
    rrow{spot,jj}=nan;
end
% Tracking proceeds backwards
for j=linspace(time, 1, time);
    
    % trajectory does not exist yet. 
for jj=1:SZ(1)
    for k=1:SZ(2)
        if isempty(col{jj,k})
            col{jj,k}=nan;
            rrow{jj,k}=nan;
        end
    end
end

    close all
    if j==time
        figure('units','normalized','outerposition',[0 0 1 1]);
        imshow(ICell{j,1},[]);
        Grid(ICell{1,1});
        cm = cell2mat(col); rm = cell2mat(rrow);
        
        for p =1:Ct(1)
            hold on
            plot(cm(p, TF), rm(p, TF),'or');
        end
        title({'Select the centroid of a single podosome','Podosomes are tracked backward in time'});
        moveon=0;
        while moveon==0
        [col{spot, j} rrow{spot,j}]= ginput();
        moveon= SelectCheck(col{spot,j});
        end
        if moveon ==2
            col{spot, j}=nan;  rrow{spot,j}= nan;
        
            continue
        end
    elseif ismember(j,[2:TF-1])
        JPL=j+1;
        PlotPoints= [col{:,JPL}]'; PlotPoints2=[rrow{:,JPL}]';
        
       
        for k=1:3
            subplot(1,3,k); imshow(ICell{j+2-k,1},[]);
            fig=gcf;  
            fig.Units= 'normalized',fig.OuterPosition = [0 0 1 1];
            hold on;
            Grid(ICell{j,1});
            if k==1
                subplot(1,3,1); plot(PlotPoints, PlotPoints2,'b.');
                subplot(1,3,1); plot(col{spot,j+1}, rrow{spot,j+1},'r.');
            end
        end
        subplot(1,3,1); title('Following Frame'); subplot(1,3,3); title('Previous Frame');
        
        subplot(1,3,2); title('Select Corresponding Podosome or Cluster');
         moveon=0;
         moveon=0;
        while moveon==0
        [col{spot, j} rrow{spot,j}]= ginput();
        moveon= SelectCheck(col{spot,j});
        end
        if moveon ==2
            col{spot, j}=nan;  rrow{spot,j}= nan;
        
            break
        end
    else
        subplot(1,2,1); imshow(ICell{j+1,1},[]);
        hold on;
        plot(col{spot,j+1}, rrow{spot,j+1},'r.');
        hold on
        subplot(1,2,2); imshow(ICell{j,1},[]);
        Grid(ICell{j,1});
         moveon=0;
        while moveon==0
        [col{spot, j} rrow{spot,j}]= ginput();
        moveon= SelectCheck(col{spot,j});
        end
       
        close
    end  
end
    saveto = {'Would you like to track another podosome? (0 or 1)'};
dlg_title = 'T';
num_lines = 1;
T = inputdlg(saveto,dlg_title,num_lines);
track=str2double(T{1});  
close ;
end


