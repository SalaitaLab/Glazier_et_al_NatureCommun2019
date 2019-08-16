function [ROIcoords, FigMaker] = KymoBoxLapse(Stack, Masking)
%This function is used to create a "kymograph" of a box region. Roxanne
%Glazier. 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%Input is an N X M cell array containing the images where N is the number of time
%points (rows) and M is the number of channels (cols).

%Output is a figure as well as the coordinates plotted. 
close all
clear Rectans FigMaker

T=length(Masking);
Sz= size(Stack); % Size of stack

% Select selection 
prompt = {'Enter Desired Selection Channel #:','Enter Desired Selection Time Point:','Vertical (V), or Horizontal (H)?','Square ROI? (Y/N)','If square, what side size? (Enter even or NaN)'};
title = 'Input';
dims = [1 35];
answered = inputdlg(prompt,title,dims)

% Plot to select
figure(20);
fig=gcf;
fig.Units='normalized';
fig.OuterPosition=[0 0 1 1];
for j = 1: Sz(2)
subplot(1, Sz(2), j); imshow(Stack{str2double(answered(2)), j},[]);
end
subplot(1, Sz(2), str2double(answered(1)));

ROIcoords=[];
%title('Select ROI here'); %Hit enter
if strcmp(answered{4},'Y')&& strcmp(answered{5},'Nan')
    coord=SquareFinder();
elseif strcmp(answered{4},'Y') && ~strcmp(answered{5},'Nan')
    [r c]=ginput(1);
    r=round(r); c=round(c);
    coord=[r-str2double(answered{5})/2 str2double(answered{5}); c-str2double(answered{5})/2 str2double(answered{5})];
else
    coord=getPosition(imrect);
    coord=round(coord);
end
if isempty(ROIcoords)
    ROIcoords=[coord(1) coord(1)+coord(3); coord(2) coord(2)+coord(4)];
end
FigMaker=cell(1, Sz(2));

colormap(gca, parula);

for j=1:T
[AData{j} DIm{j}]= AlphaPodMask25(Masking{1,j}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2)));
end

for k= 1:Sz(2)
    
        C3=coord(3); C4= coord(4);
   if strcmp(answered{3},'V')
    FigMaker{1,k}=zeros(Sz(1)*C4, C3+1);
   AD{1,2}=zeros(Sz(1)*C4, C3+1)
   else
       FigMaker{1,k}=zeros(C4+1,Sz(2)+C3);
      AD=zeros(C4+1, Sz(2)+C3);
   end
   
    for j=1:Sz(1)
        Rectans{j,k}=Stack{j,k}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));
        if strcmp(answered{3},'V')
        FigMaker{1,k}((C4*j-(C4-1)):(C4*j-(C4-1)+C4),:)=Rectans{j,k};
        clear AD; AD=[];
        AD((C4*j-(C4-1)):(C4*j-(C4-1)+C4),:)=AData{j};
    
        else
        FigMaker{1,k}(:,(C3*j-(C3-1)):(C3*j-(C3-1)+C3))=Rectans{j,k};
        AD(:,(C3*j-(C3-1)):(C3*j-(C3-1)+C3))=AData{j};
      
        
        end
    end
    DD=cat(3, zeros(size(FigMaker{k})),zeros(size(FigMaker{k})),zeros(size(FigMaker{k})));
    
    figure(k); hold on
    fig=gcf;
    fig.Units='normalized';
    fig.OuterPosition=[0 0 1 1];
    if k==1
    imshow(FigMaker{1,k},[0 300])
    else
        imshow(FigMaker{1,k},[1 2.5].*10^-9); colormap(gca, parula); hold on
        G=imshow(DD); set(G, 'AlphaData',AD);
    end
    hold on
    for j=1:(Sz(1))
        if strcmp(answered{3},'V')
        plot([1 C3],[j*C4 j*C4],'--w','LineWidth',2); hold on
        if j~=1
        G=imshow(DD); set(G, 'AlphaData',AD);
        end
        else 
        plot([j*C3 j*C3],[1 C4],'--w','LineWidth',2);    hold on;
       

        end
    end
end

end

