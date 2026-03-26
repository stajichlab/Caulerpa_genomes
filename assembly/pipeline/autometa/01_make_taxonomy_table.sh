#!/usr/bin/bash
#SBATCH -p batch --mem 128gb -N 1 -n 32 --out logs/autometa_taxonomy.%a.%A.log

module load autometa
source activate autometa
ASMDIR=asm
OUT=autometa
SAMPLES=samples.csv
COV=coverage
mkdir -p $OUT
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
	ASSEMBLY=${ASMDIR}_${asmprog}/$PREFIX.sorted.fasta
	COVTAB=${COV}/${PREFIX}.${asmprog}.coverage.tab

	echo "$ASSEMBLY $COVTAB"	
	if [ ! -f $COVTAB ]; then
	    bash pipeline/autometa/00_make_cov.sh $N
	fi
	make_taxonomy_table.py -a $ASSEMBLY -p $CPU -o $OUT/$PREFIX.$asmprog --cov_table $COVTAB
	if [ ! -f $OUT/$PREFIX.$asmprog/contig_cov_table.tab ]; then
	    make_contig_table.py -a $ASSEMBLY -c $COVTAB -o $OUT/$PREFIX.$asmprog/contig_cov_table.tab
	fi

    done
done
