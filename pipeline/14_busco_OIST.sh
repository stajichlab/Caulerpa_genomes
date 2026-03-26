#!/bin/bash
##
#SBATCH -o logs/busco.OIST.log
#SBATCH -e logs/busco.OIST.log
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

conda activate busco5

conda info --envs

export BUSCO_CONFIG_FILE=$(realpath config.ini)
export AUGUSTUS_CONFIG_PATH="/bigdata/software/augustus_3.3.3/config/"

BUSCO_PATH=$(realpath config.ini)

BUSCO_SET=chlorophyta_odb10
INDIR=genomes/OIST

busco -i $INDIR/Caulerpa_lentillifera_OIST.dna.fasta -l $BUSCO_SET -o busco_OIST -m genome --config $BUSCO_PATH --cpu 12 
busco -i $INDIR/Caulerpa_lentillifera_OIST_genemodels_v1.1.fa -l $BUSCO_SET -o busco_OIST_prot -m protein --config $BUSCO_PATH --cpu 12 


BUSCO_SET=eukaryota_odb10

busco -i $INDIR/Caulerpa_lentillifera_OIST.dna.fasta -l $BUSCO_SET -o busco_OIST_euk -m genome --config $BUSCO_PATH --cpu 12 
busco -i $INDIR/Caulerpa_lentillifera_OIST_genemodels_v1.1.fa -l $BUSCO_SET -o busco_OIST_euk_prot -m protein --config $BUSCO_PATH --cpu 12 




