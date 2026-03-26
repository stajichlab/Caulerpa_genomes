#!/usr/bin/bash
#SBATCH -p intel,batch
#SBATCH -o logs/vecscreen.log.txt
#SBATCH -e logs/vecscreen.log.txt
#SBATCH --nodes=1
#SBATCH --ntasks=16 # Number of cores
#SBATCH --mem=24G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -J calp_vec
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/

DIR=genomes
IN_GEN="CLENT.sorted.spades.filtered.ragtag.fasta"
OUT_GEN="CLENT.sorted.spades.filtered.ragtag.vecscreen.fasta"

IN_GEN2="CRAC.sorted.spades.filtered.ragtag.fasta"
OUT_GEN2="CRAC.sorted.spades.filtered.ragtag.vecscreen.fasta"


module load AAFTF

AAFTF vecscreen -i $DIR/$IN_GEN -o $DIR/$OUT_GEN -c 16
AAFTF vecscreen -i $DIR/$IN_GEN2 -o $DIR/$OUT_GEN2 -c 16



