function [StarString] = SigStars(p)
%Given a p value, this makes the right number of stars
% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
if p > .05
    StarString='ns';
elseif p <= .05 && p > .01
    StarString = '*';
elseif p <= .01 && p > .001
    StarString = '**';
elseif p<= .001 && p > .0001
    StarString= '***';
else
    StarString = '****';
end

end

