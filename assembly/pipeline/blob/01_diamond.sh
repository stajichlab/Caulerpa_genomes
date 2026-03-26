#!/usr/bin/bash
#SBATCH -p batch --mem 128gb -N 1 -n 24 --out logs/diamond.%a.log

module load miniconda3
module load diamond/2.0.4
module load blobtools
source activate blobtools
DB=/srv/projects/db/blobPlotDB/2020_10/uniprot_ref_proteomes.diamond.dmnd
SAMPLES=samples.csv
ASMDIR=asm
CPU=1
COV=coverage
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

TAXFOLDER=taxonomy
mkdir -p $TAXFOLDER

IFS=,
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do

    for asmprog in spades megahit
    do
	ASSEMBLY=$(realpath ${ASMDIR}_${asmprog}/$PREFIX.sorted.fasta)

	echo "$ASSEMBLY $PREFIX $asmprog"
	if [ ! -f $TAXFOLDER/$PREFIX.$asmprog.diamond.tab ]; then
	    diamond blastx \
		--query $ASSEMBLY \
		--db $DB -c1 --tmpdir /scratch \
		--outfmt 6 \
		--sensitive \
		--max-target-seqs 1 \
		--evalue 1e-25 --threads $CPU \
		--out $TAXFOLDER/$PREFIX.$asmprog.diamond.tab
	fi
	if [ ! -f $TAXFOLDER/$PREFIX.$asmprog.diamond.tab.taxified.out ]; then
	    blobtools taxify -f $TAXFOLDER/$PREFIX.$asmprog.diamond.tab \
		-m /srv/projects/db/blobPlotDB/2020_10/uniprot_ref_proteomes.taxids \
		-s 0 -t 2 -o $TAXFOLDER/
	fi

    done
done
