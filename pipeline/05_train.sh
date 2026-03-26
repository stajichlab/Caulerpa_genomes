#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem 650gb -p highmem
#SBATCH --time=7-00:15:00
#SBATCH --output=logs/train.%a.log
#SBATCH -J calp_train
#SBATCH --array 1-2
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/



hostname
# Load software
module load funannotate/1.8
source activate funannotate-1.8

#module switch trinity-rnaseq/2.10.0

MEM=512G

#export SINGULARITY_BINDPATH=/bigdata,/bigdata/operations/pkgadmin/opt/linux:/opt/linux
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
# Set some vars
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
export TRINITY=$(realpath `which Trinity`)
export TRINITYHOMEPATH=$(dirname $TRINITY)
export PASACONF=$(realpath ~/pasa.config.txt)

if [[ -z ${SLURM_CPUS_ON_NODE} ]]; then
    CPUS=1
else
    CPUS=${SLURM_CPUS_ON_NODE}
fi


N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
ODIR=annotate
INDIR=genomes/masked
RNA=lib/RNASeq/
SAMPLEFILE=genomes/samples.csv

IFS=,
#SPECIES,INFO,BIOPROJECT,BIOSAMPLE,SRA,LOCUS

tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read SPECIES STRAIN BIOPROJECT BIOSAMPLE SRA LOCUS
do
    echo "SPECIES is $SPECIES"
    SPECIESNOSPACE=$(echo -n "$SPECIES" | perl -p -e 's/\s+/_/g')
    BASE=$(echo -n "$SPECIES.$STRAIN" | perl -p -e 's/\s+/_/g')
    echo "sample is $BASE"
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    if [ ! -f $MASKED ]; then
	     echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
       exit
    fi

    echo $ODIR/$BASE/training
    funannotate train -i $MASKED -o $ODIR/$BASE \
   	--jaccard_clip --species "$SPECIES" --isolate $STRAIN \
  	--cpus $CPUS --memory $MEM --pasa_db mysql \
  	--left $RNA/${LOCUS}/left.fq.gz --right $RNA/${LOCUS}/right.fq.gz --stranded RF
done
