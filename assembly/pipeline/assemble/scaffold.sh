#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 16gb --out logs/scaffold.%a.log

module unload miniconda3
module load anaconda3
module load ragtag
source activate ragtag
REF=genomes/Caulerpa_lentillifera_OIST.dna.fasta 
OUTDIR=asm
SAMPLES=samples.csv
CPU=2
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
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do
	for asmtype in spades megahit
	do
		SORTED=${OUTDIR}_$asmtype/${PREFIX}.sorted.fasta
		ragtag.py scaffold $REF $SORTED --mm2-params '-x asm20' -w -o ${OUTDIR}_$asmtype/${PREFIX}.scaffolded.fasta -u
	done
done
