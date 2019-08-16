function [ICells] = Cells2Track(FolderInput)
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This function is used to grab a cell from an image stack. The folder
%contains t images that are each .tif files with Photon Counts and Fast
%FLIM Average Lifetime from SymPhoTime64. 
%Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
close all;
DataSet= FindFiles(FolderInput,'*.tif');
for t=1:length(DataSet)
    [C L]= ImportPQTif(DataSet{t,1});
    RawIms{t,1}=C; RawIms{t,2}= L;
end

% Look at last time-frame and see how many podosome-forming cells you would
% like to analyze. 
imshow(RawIms{t,1},[]);
saveto = {'# Podosome-Forming Cells to Analyze'};
dlg_title = 'Cell Ct';
num_lines = 1;
CellCt = inputdlg(saveto,dlg_title,num_lines);
CellNumber=str2double(CellCt{1});  
close;
for cct=1:CellNumber
    [MI D Rec ROIcoords] = MeanI(RawIms{t,1});
    close;
    for t=1:length(RawIms)
        for ch=1:2
            ICells{cct}{t,ch}= RawIms{t,ch}(ROIcoords(2,1):ROIcoords(2,2), ROIcoords(1,1):ROIcoords(1,2));
        end
    end
end
end

