#!/usr/bin/bash
#SBATCH -p stajichlab
#SBATCH -N 1 
#SBATCH -n 64 
#SBATCH --mem 96gb 
#SBATCH --out logs/rmasker_repbase.log
#SBATCH -J calp_rmasker_rebase
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/

SAMPFILE=genomes/samples.scaf.csv
DIR=genomes

module load RepeatMasker/4-1-1
#module load funannotate
#module unload ncbi-rmblast
#module load ncbi-rmblast/2.9.0-p2
#module unload miniconda2
#module load miniconda3
module load mcclintock
source activate mcclintock


IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX ASSEMBLY
do

	RepeatMasker -pa 64 -s -e ncbi -species Viridiplantae ${DIR}/$PREFIX.sorted.spades.filtered.ragtag.vecscreen.sorted.fasta > ${DIR}/$PREFIX.RM.out

done
