function [outputArg1,outputArg2] = Grid(Im)
%Plots a grid on the function. % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
SZ=size(Im);
hold on
for j=1:SZ(1)/50
    for k=1:SZ(2)/50
        plot(50.*[k k],[1 SZ(2)],'w:');
        plot([1 SZ(1)],50.*[j j],'w:');
    end
end
        
end

