#!/usr/bin/bash
#SBATCH -p batch --mem 24gb -N 1 -n 2 --out logs/cluster_process.%a.log

module load autometa
source activate autometa
module load git

module load autometa
source activate autometa

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
ASSEMBLY=$(ls genomes/*.fasta | grep -v masked | sed -n ${N}p)
BASE=$(basename $ASSEMBLY .fasta)
if [[ -d $BASE.autometa && -f $BASE.autometa/ML_recruitment_output.tab ]]; then
	pushd $BASE.autometa
	popd
fi
