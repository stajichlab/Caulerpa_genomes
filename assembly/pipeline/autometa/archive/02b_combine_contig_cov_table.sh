#!/usr/bin/bash
#SBATCH -N 1 -n 1 --mem 3gb -p short --out logs/contig_cov_table.%a.log

module load autometa
source activate autometa
module load git

OUT=autometa
N=${SLURM_ARRAY_TASK_ID}
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi


if [ -z $N ]; then
 N=$1
fi

if [ -z $N ]; then
 echo "need to provide a number by --array or cmdline"
 exit
fi
IFS=,
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do

    for asmprog in spades megahit
    do
	ASSEMBLY=$(realpath ${ASMDIR}_${asmprog}/$PREFIX.sorted.fasta)
	COVTAB=$(realpath ${COV}/$PREFIX.${asmprog}.coverage.tab)

	if [ ! -f ${COV}/$PREFIX.$asmprog.contig_cov.tab ]; then
	    ~/src/autometa-hyphaltip/pipeline/make_contig_table.py -a $ASSEMBLY \
		-c $COVTAB \
		-o $OUT/$PREFIX.$asmprog/$PREFIX.contig_cov_table.tab
	fi
    done
done
