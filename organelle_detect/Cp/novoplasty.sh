#!/usr/bin/bash -l
#SBATCH -c 4 --mem 24gb 

module load AAFTF
NOVOPlasty4.3.5.pl -c Cp_config_Clent.txt
