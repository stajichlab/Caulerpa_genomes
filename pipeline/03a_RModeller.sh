#!/usr/bin/bash
#SBATCH -p stajichlab 
#SBATCH -N 1 
#SBATCH -n 64 
#SBATCH --mem 96gb 
#SBATCH --out logs/rmodel.log
#SBATCH -J calp_repeat
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


SAMPFILE=genomes/samples.scaf.csv
DIR=genomes

CPU=$SLURM_CPUS_ON_NODE # set the CPUS dynamicall for the job
if [ -z $CPU ]; then # unless this is not really a slurm job
 CPU=2 # set the number of CPUs to 2
fi

module unload miniconda2
module load miniconda3
module load funannotate
module load RepeatModeler/2.0.1

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX ASSEMBLY
do

	if [ ! -f $PREFIX.translation ]; then # assumes using rmblast as default
		BuildDatabase -name $PREFIX ${DIR}/$PREFIX.sorted.spades.filtered.ragtag.vecscreen.sorted.fasta
	fi

	# this can take 2-48 hrs depending on genome size - you may need to set job running
	RepeatModeler -database $PREFIX -LTRStruct -pa $CPU

done
