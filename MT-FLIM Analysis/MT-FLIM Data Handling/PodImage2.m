classdef PodImage2
    %This defines an image object
    % Glazier, Brockman, Bartle, Mattheyses, Destaing, and Salaita. 2019. 
    properties
        Cts_PreCorr
        FileAddress
        Condition
        Counts
        AvLife
        BAv_Cts
        BAv_Life
        PodAvs
        DeltaPodAvs
        Percent 
        MeanPercent
        Mask
        DepletionSize
        Props
        MeanDensity
        ClusterIm
        CellRegion
        CtsCutoff
        BDevs
        ClusterMap
        BackgroundMap
        PodMaps2Process
        AvLifeNAN
        CountsNAN
        NANMask
        ICellMask
        RandB
        BR
    end
    
    methods
        %Define an image with podosomes
        function PodImage2 = PodImage(FileAddress,Condition, Counts, AvLife)
            PodImage2.FileAddress= FileAddress;
            PodImage2.Counts= Counts;
            PodImage2.AvLife= AvLife;
            PodImage2.CellCount= CellCount;
            PodImage2.Condition= Condition;
            PodImage2.BAv_Cts=Cts_Background;
            PodImage2.BAv_Life=Life_Background;
          
       %}
        end
            
    end
    
end

