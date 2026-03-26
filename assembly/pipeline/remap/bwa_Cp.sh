#!/bin/bash
#SBATCH -N 1 -n 24 --mem 32gb --out logs/bwa_Cp.%a.log
module load bwa
module load samtools/1.11
module load bedtools

GENOME=Cp/Cp.dna.fasta
GENOME=Cp/NC_039377.fa
GENOMEDIR=Cp
ABBREV=Cp
FOLDER=input
SAMPLES=samples.csv
ALNDIR=Cp_aln
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
	N=$1
fi
if [ -z $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
mkdir -p $ALNDIR
IFS=,
sed -n ${N}p $SAMPLES | while read FOLDER PREFIX FILESTEM
do
	INLEFT=$FOLDER/${FILESTEM}_1.fq.gz
	INRIGHT=$FOLDER/${FILESTEM}_2.fq.gz
	if [ ! -f  $ALNDIR/${PREFIX}.$ABBREV.bam ]; then
		bwa mem -t $CPU $GENOME $INLEFT $INRIGHT | samtools sort -O bam -o $ALNDIR/${PREFIX}.$ABBREV.bam -T /scratch/${PREFIX} --threads $CPU
	fi
	if [ ! -f $ALNDIR/${PREFIX}.$ABBREV.genome_cov.bed ]; then
		samtools view -h -F 4 $ALNDIR/${PREFIX}.$ABBREV.bam | genomeCoverageBed -ibam - > $ALNDIR/${PREFIX}.$ABBREV.genome_cov.bed
#		genomeCoverageBed -ibam $ALNDIR/${PREFIX}.$ABBREV.bam > $COV/${PREFIX}.$ABBREV.genome_cov.bed
	fi
	if [ ! -f $ALNDIR/${PREFIX}.$ABBREV.coverage.tab ]; then
		module load autometa
		contig_coverage_from_bedtools.pl $ALNDIR/${PREFIX}.$ABBREV.genome_cov.bed > $ALNDIR/${PREFIX}.$ABBREV.coverage.tab
	fi
done
