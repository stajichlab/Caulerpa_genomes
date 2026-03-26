#!/usr/bin/bash

#SBATCH -p batch --mem 64gb -N 1 -n 24 --out logs/autometa_run.%a.log
module unload miniconda2
module unload miniconda3
module load anaconda3
module load autometa
source activate autometa
module load git
which git
SAMPLES=samples.csv
COV=coverage
ASMDIR=asm

OUT=autometa
mkdir -p autometa

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
#	COVTAB=$(realpath ${COV}/$PREFIX.${asmprog}.coverage.tab)
	COVTAB=contig_cov_table.tab 
	echo "ASM=$ASSEMBLY COV=$COVTAB"
	if [ -d $OUT/$PREFIX.$asmprog ]; then
	    pushd $OUT/$PREFIX.$asmprog
	     ~jstajich/src/autometa-hyphaltip/pipeline/run_autometa.py -k bacteria \
		-a Bacteria.fasta --ML_recruitment \
		--processors $CPU --length_cutoff 1500 \
		--taxonomy_table taxonomy.tab -o ./ --cov_table $COVTAB
	    
	    ~jstajich/src/autometa-hyphaltip/pipeline/cluster_process.py \
		--bin_table ML_recruitment_output.tab \
		--column ML_expanded_clustering \
		--fasta Bacteria.fasta --do_taxonomy \
		--db_dir ~/src/autometa-hyphaltip/databases  \
		--output_dir Bacteria_cluster_process_output
	    Rscript ../../Rscripts/autometa_viz.R

	    popd
	fi
    done
done
