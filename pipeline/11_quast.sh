#!/bin/bash
##
#SBATCH -o logs/quast_ragtag.log.txt
#SBATCH -e logs/quast_ragtag.log.txt
#SBATCH --nodes=1
#SBATCH --ntasks=12 # Number of cores
#SBATCH --mem=60G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=24:00:00
#SBATCH -J calp_ragtag_quast
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


module load busco

INDIR=genomes/masked
REF=/rhome/cassande/shared/projects/Caulerpa/gDNA/genomes/Caulerpa_lentillifera_OIST.dna.fasta

/rhome/cassande/bigdata/software/quast-5.0.2/quast.py $INDIR/Caulerpa_lentillifera.spades.ragtag.masked.fasta $INDIR/Caulerpa_racemosa.spades.ragtag.masked.fasta $REF --threads 12 --eukaryote --space-efficient --conserved-genes-finding

