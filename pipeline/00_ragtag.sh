#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 16gb --out logs/scaffold.%a.log
#SBATCH -J calp_ragtag
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/
#SBATCH --array 1-2

module unload miniconda3
module load anaconda3
module load ragtag
source activate ragtag

REF=/rhome/cassande/shared/projects/Caulerpa/gDNA/genomes/Caulerpa_lentillifera_OIST.dna.fasta
DIR=genomes
SAMPFILE=genomes/samples.scaf.csv

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
        N=$1
fi

if [ -z $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit

fi


IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX ASSEMBLY
do

    ragtag.py scaffold $REF ${DIR}/$ASSEMBLY --mm2-params '-x asm20' -w -o ${DIR}/scaffold/${PREFIX}.scaffolded.fasta -u
  
done




