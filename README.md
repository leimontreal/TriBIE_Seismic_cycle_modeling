# Calculate the stiffness matrix of shear stress and normal stress
   
## step-by-step manual
1. Prepare the fault geometry file as shown in the *.gts file, the file includes the xyz-location of the vertices of triangular and the cell with corresponding vertices's number;(The mesh of the fault plane is using Trelis pro.)
2. Change the filename of *.gts in the calc_*.f90 file and the number of cpu used in the cluster;
3. Use the command to compile the *.f90 files: 
    mpif90 sub*.f90 mod*.f90 m_*.f90 calc_*.f90 -o *** 
5. Submit the task using the *.bash file.
