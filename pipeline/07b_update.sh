#!/bin/bash
#SBATCH -p batch 
#SBATCH --time 3-0:00:00 
#SBATCH --ntasks 16 
#SBATCH --nodes 1 
#SBATCH --mem 24G 
#SBATCH --out logs/update.%a.log
#SBATCH -J calp_update
#SBATCH --array 1
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


#module unload miniconda2 miniconda3
module purge
module load funannotate/1.8
#source activate funannotate-1.8

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
# Set some vars

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
export PASAHOME=$(dirname  `which Launch_PASA_pipeline.pl`)
export TRINITY=$(realpath `which Trinity`)
export TRINITYHOMEPATH=$(dirname $TRINITY)
export PASACONF=$(realpath ~/pasa.config.txt)




CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

INDIR=genomes/masked
OUTDIR=annotate
SAMPFILE=genomes/CLENT.csv

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`
if [ -z "$MAX" ]; then
    MAX=0
fi
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi
IFS=,
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN BIOSAMPLE BIOPROJECT SRA LOCUSTAG
do
    BASE=$(echo -n "$SPECIES.$STRAIN" | perl -p -e 's/\s+/_/g')
    TEMPLATE=$(realpath lib/sbt/draft.sbt)
    funannotate update --cpus $CPU -i $OUTDIR/$BASE --out $OUTDIR/$BASE --sbt $TEMPLATE --pasa_db mysql 
done
