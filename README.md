# Align-3D 
This MATLAB software package provides a user-friendly interface for selecting similar particles in 3D acquired using super-resolution localization microscopy (STORM, DNA-PAINT, MINFLUX, etc.) and aligning them to a given template.

# Overview of the framework
In many areas of structural biology, multiple datasets from similar structures can be combined to obtain more accurate and detailed structural information. However, these structures are often randomly oriented and shifted, and must be aligned before they can be combined. This software package provides a simple and robust method for aligning structures or particles in three dimensions. Each structure is aligned to a given template using a Monte Carlo–based approach that iteratively applies random rotations and translations to minimize the summed distance between the structure and the template.

# Software package overview
This software package includes a folder named “Codes”, a MATLAB script “Example_Align3D_NPC.m”, and two MAT-files, “Template_NPC.mat” and “Data_rotatedNPC.mat”.
The “Codes” folder contains all functions and methods required by the software package.
The script “Example_Align3D_NPC.m” serves as a demonstration for aligning a simulated nuclear pore complex (NPC) structure to a given template.
The two MAT-files contain the NPC template structure and a set of simulated, randomly rotated data used in the example.

# How to run the software with and without the gui
To use this software, you need to have MATLAB 2022 or higher versions. Simply download the software and set your MATLAB path to the software folder "Align-3D". You can now open the example script "Example_Align3D_NPC.m" and simply run it. It will load the template and the data and will align them. To use the gui, you should add the path to the folder "Codes" and type "alignParticles_gui" in the command window. The gui will pop-up. This gui provides a user friendly interface to pick particles and then
align them using a given template. The gui has two section: "piack particles" and "align paticle". In the following, the description for each
button and parameter is given. 

pick particles section:

   LOAD DATA: 
   This button allow picking and loading the localizations. The
   localizations can be either 2D or 3D and the parameters must be (Xc,Yc,Zc)
   or (Xt,Yt,Zt). When the data is loaded the localizations are plotted on
   the left. The loaded data contains multiple similar structures, which
   can be picked one-by-one by zooming on them.
   
   ADD LOCS:
   After zooming on an individual structure, this button adds the
   sturuvture to the set of picked particles and highlights it in red.
   
   ROI counts: 
   Shows the number of picked structures/particles/ROIS.
   
   SAVE PARTICLES:
   After picking all the structures, this button will save them into a mat-file

align particles section:

   LOAD PARTICLES:
   This button loads the set of previously picked and saved particles.
   
   LOAD TEMPLATE:
   This button loads the template used for alignment.
   
   ALIGN PARTICLES:
   This button starts aligning the particles with the give template. The
   progress is shown in the tab bellow. 
   
   SAVE ALIGNED:
   This button save the aligned particles into a mat-file.

   GEN IMAGE: 
   This button opens up a new sub-gui to filter out some of the
   localizations and reconstruct an image from the remaining ones.
   
   LOAD DATA: 
   This button is used to load the aligned particles saves in the previous
   section. If you have already aligned and saved the particles, you won't
   need to load them again as they already exist in the work enviroment.
   
   FIND NND:
   This button finds the neighboring localization distances where the
   neighbor order is given in the text to the right. 
   
   DISTANCE THRESH:
   The threshold used for filtering. All the localizations with
   neighboring distances larger than this threhsold will be filter out.
   
   MAKE IMAGE: 
   This button generates images from the remaining localizations after
   filtering and uses the zoom factor given on the right.
   
   SAVE IMAGE:
   This will save the generaged images in the png-format.

   # Support
   If you happen to have any questions please shoot me an email at:

   Mohamadreza Fazel, fazel.mohamadreza@gmail.com
   
