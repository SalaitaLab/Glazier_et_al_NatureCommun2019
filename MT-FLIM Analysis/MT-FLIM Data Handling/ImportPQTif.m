function [ Cts, AvLife ] = ImportPQTif( Filename )
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%This function will open and display lifetime images. This assumes that
%images contain two channels, 1 - Counts, 2- Average Lifetime. For two
%detector images, this will need to be adjusted. Images should be imported
%in tif form. Filename is a string. Lifetime image threshold values can be
%adjusted if needed. 

Cts=imread(Filename,1);
AvLife=imread(Filename,2);


end

