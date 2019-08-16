function [ Paths] = FindFiles(FolderPath, Ext)
%This function will collect all the files names that you want to open into
%a cell.
%   Input: Folderpath is a string containing the folder path. All files of
%   a certain type in this folder will be uploaded,so make sure that you.
%   Ext is the file type, like .dat
%   want all the data in the folder, or create a new one. 
%   Output: Data is an nx1 cell containing the file names of interest
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
Set=dir(fullfile(FolderPath,Ext));
Paths=cell(length(Set),1);
PathSet=cell(length(Set),1);
Filenames=cell(1,length(Set));
ImageTitle=cell(1,length(Set));
for j=1:length(Set)
    Paths{j,1}=fullfile(FolderPath,Set(j).name);
end

