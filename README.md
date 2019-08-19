# Podosome-Paper-Files-

Commented analysis code for Glazier, Brockman, Bartle, Matteyses, Destaing, and Salaita. In revision, 2019. 
Here we include a combination of scripts and functions to perform analysis. <br/>
For assistance, please email k.salaita@emory.edu and cc roxanne.glazier@emory.edu <br/>
Files are sorted into folders by category, and the Supporting Files and Functions folder contains basic functions used by multiple analyses. <br/><br/>

Overview:
Fig 1 - To perform depletion versus actin content analysis, use the LifeActAnalysis script, which should be run 1 section at a time. To perform FRAP analysis, run the FRAPAnalysis script. <br/>
Fig 2 - To perform MT-FLIM Analysis follow the following steps: (See SI Figure 11 for visual workflow)<br/>
        1. Perform Intensity Calibration with the IntensityCal Script<br/>
        2. Perform Percent Open Calibration with the PercOpen_Intensity Script<br/>
        3*. Perform Illumination Profile Correction with FLIM_Illum Calcs Script<br/>
        4*. Mask MT-FLIM Images with the ImageBasedMTFLIMAnalysis Script <br/>
        5*. Perform MTFLIM Cutoff Analysis Script to determine your cutoff variables*<br/>
          * 3-5) If desired to determine cutoff variables and understand the relationship between photon counts and               lifetimeNote that some of our display items are written for our cutoffs, such as the KymoBox Function for             timelapses <br/>
        6. Run the MT-FLIM_Script Script to process your MT-FLIM Data<br/>
        To perform MT-FLIM Tracking and plotting (Fig 2g and SI 14)<br/>
        1. Run the TrackPod_Script<br/>
        2. Run the TrackCluster_Script. You will need to use https://imagej.net/TrackMate to perform tracking, but this script will generate a cluster mask to track and plot the final tracking results. 
Fig 3 - Codes for MFM are available at https://experiments.springernature.com/articles/10.1038/nmeth.4536
Fig 4 - First, perform steps 1 - 5 as described for Fig 2. Then, run MTFLIM_Script_DrugAnalysis, which will do before and after comparison of drug treated cells. <br/>
Fig 5 - PCB analysis methods are shown in SI 22. To peform PCB tension analysis (per cell), run the PhotocleavableBiotin_Tension script section-by-section. To perform PCB protrusion analysis (per podosome), run the PhotocleavableBiotin_Density script section-by-section.<br/>
Fig 6 - To perform TGT analysis, run the TGT script section-by-section. This will quantify percent forming podosomes, cell area, number of podosomes, and mean depletion. <br/>
Fig 7 - To simply model podosome tensile forces, run the ModelTension script. <br/><br/>
        

These files work in conjuction with ND Bioformats. https://www.openmicroscopy.org/bio-formats/ This program must be installed and on your MATLAB path for these codes to run. <br/>
You also must have SEM_calc from https://www.mathworks.com/matlabcentral/fileexchange/26508-notboxplot to run these codes. Finally, for the clustering time lapse analysis, you must download https://www.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack. 

