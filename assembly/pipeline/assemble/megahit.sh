#!/bin/bash
#SBATCH -N 1 -n 24 --mem 24gb --out logs/megahit.%a_%A.log

module load AAFTF/git-live
module load megahit
MEM=24
OUTDIR=asm_megahit
SAMPLES=samples.csv
WORKDIR=working_AAFTF
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
mkdir -p $OUTDIR $WORKDIR
IFS=,
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do
	INLEFT=$FOLDER/${FILESTEM}_1.fq.gz
	INRIGHT=$FOLDER/${FILESTEM}_2.fq.gz
	LEFTTRIM=$WORKDIR/${PREFIX}_1P.fastq.gz
	RIGHTTRIM=$WORKDIR/${PREFIX}_2P.fastq.gz
	LEFT=$WORKDIR/${PREFIX}_filtered_1.fastq.gz
	RIGHT=$WORKDIR/${PREFIX}_filtered_2.fastq.gz

	if [ ! -f $LEFT ]; then
	    if [ ! -f $LEFTTRIM ]; then
		AAFTF trim --mem $MEM --method bbduk --left $INLEFT  --right $INRIGHT -o $WORKDIR/${PREFIX} -c $CPU
	    fi
 	    ~/projects/AAFTF/scripts/AAFTF filter --mem $MEM -c $CPU --left $LEFTTRIM --right $RIGHTTRIM --aligner bbduk -o $WORKDIR/${PREFIX}
	fi
	
	if [[ -s $LEFT && -s $LEFTTRIM ]]; then
	    unlink $LEFTTRIM
	    unlink $RIGHTTRIM
	fi

	ASMFILE=$OUTDIR/${PREFIX}.megahit.fasta
	VECCLEAN=$OUTDIR/${PREFIX}.vecscreen.fasta
#	PURGE=$OUTDIR/${PREFIX}.sourpurge.fasta
#	CLEANDUP=$OUTDIR/${PREFIX}.rmdup.fasta
#	PILON=$OUTDIR/${PREFIX}.pilon.fasta
	SORTED=$OUTDIR/${PREFIX}.sorted.fasta
	STATS=$OUTDIR/${PREFIX}.sorted.stats.txt
	if [ ! -f $ASMFILE ]; then
	    AAFTF assemble --mem $MEM --left $LEFT --right $RIGHT -o $ASMFILE -c $CPU --method megahit
	fi
	if [ ! -f $VECCLEAN ]; then
	    AAFTF vecscreen -i $ASMFILE -o $VECCLEAN -c $CPU
	fi
	if [ ! -f $SORTED ]; then
	    AAFTF sort -i $VECCLEAN -o $SORTED
	fi
	
	if [ ! -f $STATS ] ; then
	    AAFTF assess -i $SORTED -r $STATS
	fi
done
