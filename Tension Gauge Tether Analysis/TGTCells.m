classdef TGTCells
    %This class is used alonglide the TGT Analysis script to save the masks
    %generated in case podosomes need further analysis later on. 
    %   % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
    
    properties
        RICM %RICM 
        PodCount
        Fluor %Cy3B
        PodFinder %Map of labeled podosomes
        CellMask %Cell ROIs
        B %Background Cy3B intensity
        Rep %Surface/CellFlask Number 
        ImageN %Image Number in array
        Mask
        PodLoc
        RTherePods
        Depletion
        BDevs
        Area
    end
    
    methods
        function TGT= TGTCells(RICM, Fluor);
            TGT.RICM=RICM;
            TGT.Fluor=Fluor;
        end
    end
end

