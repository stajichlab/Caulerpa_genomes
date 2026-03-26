#!/bin/bash
##
#SBATCH -o logs/13c_busco_prot.log
#SBATCH -e logs/13c_busco_prot.log
#SBATCH --nodes=1
#SBATCH --ntasks=12 # Number of cores
#SBATCH --mem=60G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=48:00:00
#SBATCH -J calp_busco
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


module unload miniconda2
module load augustus/3.3.3
module load hmmer 
module load ncbi-blast/2.2.31+ 
module load R
module unload anaconda3

module load miniconda3

source activate busco5

conda info --envs

export BUSCO_CONFIG_FILE=$(realpath config.ini)
export AUGUSTUS_CONFIG_PATH="/bigdata/software/augustus_3.3.3/config/"

BUSCO_PATH=$(realpath config.ini)

BUSCO_SET=chlorophyta_odb10

DIR=filtered_annotate/v3
CLENT=$DIR/Caulerpa_lentillifera.prot.fa
CRAC=$DIR/Caulerpa_racemosa.prot.fa

busco -i $CLENT -l $BUSCO_SET -o busco_CLENT_prot_v2 -m protein --config $BUSCO_PATH --cpu 12 -f 

busco -i $CRAC -l $BUSCO_SET -o busco_CRAC_prot_v2 -m protein --config $BUSCO_PATH --cpu 12 -f 

