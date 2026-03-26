#!/usr/bin/bash
#SBATCH -p short --mem 8gb -N 1 -n 1 --out logs/blob.%a.log
module load miniconda3
module load blobtools/1.1.1
source activate blobtools

ASMDIR=asm
SAMPLES=samples.csv
COV=coverage
WORKDIR=working_AAFTF
TAXFOLDER=taxonomy
OUTDIR=blobPlots
ASMDIR=asm

mkdir -p $OUTDIR
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
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
	BAM=${COV}/$PREFIX.${asmprog}.remap.bam
	COVTAB=$BAM.cov
	PROTTAB=${TAXFOLDER}/$PREFIX.$asmprog.diamond.tab
	PROTTAX=${TAXFOLDER}/$PREFIX.$asmprog.diamond.tab.taxified.out

	if [ ! -f $OUTDIR/${PREFIX}.$asmprog.aa.blobDB.json ]; then
	    blobtools create -i $ASSEMBLY -c $COVTAB -t $PROTTAX -o $OUTDIR/${PREFIX}.$asmprog.aa
	fi

	time blobtools view -r all -i $OUTDIR/${PREFIX}.$asmprog.aa.blobDB.json -o $OUTDIR

	for rank in phylum order genus
	do
	    if [ ! -f $OUTDIR/$PREFIX.$asmprog.aa.blobDB.json.bestsum.$rank.p8.span.100.blobplot.read_cov.bam0.png ]; then
		blobtools plot -i $OUTDIR/$PREFIX.$asmprog.aa.blobDB.json -r $rank -o $OUTDIR
	    fi
	done
    done
done
