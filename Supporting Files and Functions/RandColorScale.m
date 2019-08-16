function [ Random ] = RandColorScale()
%This function generates a random colorscale with black as the first value.% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
%

Random=[0 0 0];
for j=2:100;
    Random(j,:)=[rand(1) rand(1) rand(1)];
end


end

