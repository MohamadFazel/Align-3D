# Align-3D 
This MATLAB software package provides a user-friendly interface for selecting similar particles in 3D and aligning them to a given template.

# Overview of the framework
In many areas of structural biology, multiple datasets from similar structures can be combined to obtain more accurate and detailed structural information. However, these structures are often randomly oriented and shifted, and must be aligned before they can be combined. This software package provides a simple and robust method for aligning structures or particles in three dimensions. Each structure is aligned to a given template using a Monte Carlo–based approach that iteratively applies random rotations and translations to minimize the summed distance between the structure and the template.

# Software package overview
This software package includes a folder named “Codes”, a MATLAB script “Example_Align3D_NPC.m”, and two MAT-files, “Template_NPC.mat” and “Data_rotatedNPC.mat”.

The “Codes” folder contains all functions and methods required by the software package.

The script “Example_Align3D_NPC.m” serves as a demonstration for aligning a simulated nuclear pore complex (NPC) structure to a given template.

The two MAT-files contain the NPC template structure and a set of simulated, randomly rotated data used in the example.
