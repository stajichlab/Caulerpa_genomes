#!/usr/bin/bash
#SBATCH -p intel,batch
#SBATCH -o fun.sort.log.txt
#SBATCH -e fun.sort.log.txt
#SBATCH --nodes=1
#SBATCH --ntasks=8 # Number of cores
#SBATCH --mem=24G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -J calp_fun_sort
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/genomes/


IN="CLENT.sorted.spades.filtered.ragtag.vecscreen.fasta"
OUT="CLENT.sorted.spades.filtered.ragtag.vecscreen.sorted.fasta"

IN2="CRAC.sorted.spades.filtered.ragtag.vecscreen.fasta"
OUT2="CRAC.sorted.spades.filtered.ragtag.vecscreen.sorted.fasta"


module load funannotate/1.8
source activate funannotate-1.8



funannotate sort -i $IN -o $OUT
funannotate sort -i $IN2 -o $OUT2

