# TDM_model
This model is another way to calculate the properties that others would need LOPTICS in VASP that is computationally expensive. I used this technique to calculate Faraday rotation for YIG and similar materials. Please download the readme file for full description of the contents of the depository. 
[readme.pdf](https://github.com/smileysushree/TDM_model/files/13357828/readme.pdf)

KEYWORDS: VASP, LOPTICS, Dielectric, ALGO=Exact, Faraday Rotation, Transition dipole moment Model

This study presents a novel methodology for computing the Faraday Rotation of magneto-optical materials. Initially, calculations for magneto-optics properties were conducted using the Vienna Ab initio Simulation Package (VASP)’s LOPTICS tagline. The approach was tried for the parent compound Yttrium Iron Garnet (YIG) [1]. However, due to the extensive nature of the YIG model comprising 160 atoms, the memory required for diagonalization exceeded the Central Processing Unit (CPU) capacity in the High-Performance Computing (HPC) system.

To overcome this limitation, an alternative approach was devised. This model utilizes the Vaspkit software [2] to compute a Transition Dipole Moment (TDM) matrix, encompassing all the 3d orbitals of Iron (Fe). Iron was chosen for this calculation as our material, YIG, and its derivatives get their Faraday rotation from the transition in iron. This matrix was specifically calculated from the 3di orbitals to all the 3df orbitals of Fe within the magneto-optical materials. Subsequently, a custom MATLAB code for equations detailed in the paper [1] was employed. The MATLAB code incorporated equations delineated in the aforementioned paper: equation 1 for ri_polar.m, equations 4 and 5 for tdm_to_fr.m . 

The pertinent data files provided are demo files that are essential to follow through for TDM model
1.	INPUT files from VASP necessary for band structure computations (Need to compute your own WAVECAR file. WAVECAR for my system is too large for github. )
2.	A bash script (tdm_extraction.sh) to calculate the transition dipole moment matrix from Vaspkit for all the initial to final bands. It contains two Python codes as a part of the function. These matrixes are also read as an input file for the MATLAB code.
a.	A Python code (debye_value.py) to access the transition amplitude for the Faraday rotation calculations.
b.	A python code (TDM_matrix.py) to make the matrix out of the rows formed as a result of the 2 and 2(a) steps. This also uses a Python code check_file_rows.py to make sure that the calculation for all the initial band numbers was performed with no error. It is a quick step to see if any initial number requires fresh calculation or not. 
3.	Python code TDM_energy_matrix.py uses file BAND.dat to give two .dat files TDM_ediff for UP and DW transition. These matrixes are also read as an input file for the MATLAB code. A demo BAND.dat file is also provided to understand the code. The code’s output TDM_ediff_DW.dat and TDM_ediff_UP.dat are also provided. 
4.	A MATLAB code for post-processing. Code faraday_rotation_calculation.m used the function ri_polar.m to calculate the Faraday rotation from the matrix created in the above steps and gives the final figure.
These resources collectively enable the comprehensive assessment of Faraday rotation properties in the studied materials. In addition to these computational advancements, it is noteworthy that the results obtained through this method demonstrated a remarkable alignment with experimental calculations, validating the efficacy of our approach in accurately predicting the Faraday Rotation properties of the magneto-optical materials.

References:
[1] Sushree S. Dash and Miguel Levy, "Surface magneto-optics in yttrium iron garnets," Opt. Mater. Express 13, 1663-1676 (2023)
[2] V. Wang, N. Xu, J.-C. Liu, G. Tang, and W.-T. Geng, “Vaspkit: A user-friendly interface facilitating high-throughput computing and analysis using VASP code,” Comput. Phys. Commun. 267, 108033 (2021)


