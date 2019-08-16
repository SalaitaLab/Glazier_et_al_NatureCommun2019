function [ImageData] = LoadTriplicateBS(FN,Folders)
%This function will load in 2 channel intensity based data in triplicate.
%The files should be organized such that FN contains 3 folders each with a
%replicate. Folderes is a cell array containing the names of each of these
%in string form. 
%   Output is RICM and Fluorescence, both background subtracted (200). 
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
for j=1:3
    Files12=FindFiles(fullfile(FN,Folders{j}),'*.nd2');
    
    for k=1:length(Files12)
        UnzipFiles12{j,k}=bfopen(Files12{k});
       
    s=size(UnzipFiles12{j,k}{1,1});
    if ~isequal(s,[2,2])
        UnzipFiles12{j,k}=[];
    else
        for l=1:2
        ImageData{j,k}{l,1}=double(UnzipFiles12{j,k}{1,1}{l,1})-200;
    end
    end
end
end

