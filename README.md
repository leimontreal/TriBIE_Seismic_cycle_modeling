# TriBIE_Seismic_cycle_modeling
Conduct numerical modeling of seismic cycle on uniplanar fault using the Boundary Element Method with normal stress evolution and oblique slip
Notice:
In the nature, oblique slip on a unplanr fault will be changed by the local stress evoltuion. However, in our code the oblique slip direction is prescribed.
To achieve time-variable slip direction in the computational framework, one would need to 1) calculate the shear and normal stress changes due to strike-slip and dip-slip components on each element, respectively, therefore four sets of matrix multiplication (as opposed to two sets in Equations 1 and 2) at each time of the ODE evaluation (there could be multiple times of such evaluations in each time step), and 2) update the stress tensor based on the stress changes in step 1) and update the slip vector for each element. Such an approach is possible, but the computational cost is much higher with our boundary integral method. 
## step-by-step manual
1. Prepare the stiff matrix files including the shear stress and normal stress matrix files;
2. Change the inputting parameters in the parameter*.txt;
3. Use the command to compile the *.f90 files: 
    mpif90 phy3d*.f90 3d_tri*.f90 -o *** 
5. Submit the task using the *.bash file.
