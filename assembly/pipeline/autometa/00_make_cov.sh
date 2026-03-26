#!/usr/bin/bash
#SBATCH -N 1 -n 48 -p short --mem 64gb --out logs/make_cov.%a.log

module load bwa
module load samtools/1.11
module load autometa
source activate autometa
module load bedtools

ASMDIR=asm
SAMPLES=samples.csv
COV=coverage
WORKDIR=working_AAFTF

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

mkdir -p $COV
IFS=,
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do

    for asmprog in spades megahit
    do
	ASSEMBLY=${ASMDIR}_${asmprog}/$PREFIX.sorted.fasta
	BAM=${COV}/$PREFIX.${asmprog}.remap.bam
	COVTAB=${COV}/$PREFIX.${asmprog}.coverage.tab
	FWD=$WORKDIR/${PREFIX}_filtered_1.fastq.gz
	REV=$WORKDIR/${PREFIX}_filtered_2.fastq.gz
	
	if [ ! -f $BAM ]; then
	    if [ ! -f $ASSEMBLY.bwt ]; then
		bwa index $ASSEMBLY
	    fi
	    bwa mem -t $CPU $ASSEMBLY $FWD $REV | samtools sort --threads $CPU -T /scratch -O bam -o $BAM	    
	fi
	if [ ! -f $BAM.bai ]; then
	    samtools index $BAM
	fi
	if [ ! -f $COVTAB ]; then
	    # can replace this also with samtools faidx and a cut cmd
	    #fasta_length_table.pl $ASSEMBLY > $PREFIX.genome.lengths
	    genomeCoverageBed -ibam $BAM  > coverage/$PREFIX.genome_cov.bed
	    contig_coverage_from_bedtools.pl coverage/$PREFIX.genome_cov.bed > $COVTAB
	fi
    done
done
