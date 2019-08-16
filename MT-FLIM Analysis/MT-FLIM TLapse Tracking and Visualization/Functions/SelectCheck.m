function [moveon] = SelectCheck(G)
%This function is an important checking step in tracking and ensures one
%point is selected per spot.

% Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
        if isempty(G);
            saveto = {'You did not enter a location. To try again, Press 1. If this trajectory has ended and you wish to move to the next, Press 0'};
        dlg_title = 'Cell Ct';
            num_lines = 1;
            CellCt = inputdlg(saveto,dlg_title,num_lines);
            Ans=str2double(CellCt{1});  
            if Ans == 1
                moveon = 0
            elseif Ans == 0
            moveon= 2;
            end
        elseif ~isequal([1 1], size(G))
           title('Error - Please select one point only');
            moveon=0;
        else 
            moveon=1
        end
        
end

