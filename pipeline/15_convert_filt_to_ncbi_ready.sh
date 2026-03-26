#!/bin/bash
#SBATCH -p batch,intel 
#SBATCH --time 1-0:00:00 
#SBATCH --ntasks 12 
#SBATCH --nodes 1 
#SBATCH --mem 24G 
#SBATCH --out logs/convert.%a.log
#SBATCH -J caulerpa_genbank
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


module unload miniconda2 miniconda3
module load funannotate/1.8

DIR=filtered_annotate
SBTDIR=lib/sbt/
#SAMPFILE=
SBT=draft.sbt


GFF=Caulerpa_lentillifera_v1_filt.gff3
FASTA=Caulerpa_lentillifera_spades.ragtag.scaffolds.kept5000.fa
PREFIX=Caulerpa_lentillifera

funannotate util gff2prot -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.prot.fa
funannotate util gff2tbl -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.tbl
funannotate util tbl2gbk -i $DIR/$PREFIX.tbl -f $DIR/$FASTA -s "Caulerpa lentillifera" --sbt $SBTDIR/$SBT --out $DIR/$PREFIX
funannotate util gbk2parts -g $DIR/$PREFIX.gbk -o $DIR/$PREFIX

GFF=Caulerpa_racemosa_v1_filt.gff3
FASTA=Caulerpa_racemosa_spades.ragtag.scaffolds.kept5000.fa
PREFIX=Caulerpa_racemosa

funannotate util gff2prot -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.prot.fa
funannotate util gff2tbl -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.tbl
funannotate util tbl2gbk -i $DIR/$PREFIX.tbl -f $DIR/$FASTA -s "Caulerpa racemosa" --sbt $SBTDIR/$SBT --out $DIR/$PREFIX
funannotate util gbk2parts -g $DIR/$PREFIX.gbk -o $DIR/$PREFIX



#IFS=,
#tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX GFF FASTA SBT STRAIN
#do 
#	funannotate util gff2prot -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.prot.fa
#	funannotate util gff2tbl -g $DIR/$GFF -f $DIR/$FASTA > $DIR/$PREFIX.tbl
#	funannotate util tbl2gbk -i $DIR/$PREFIX.tbl -f $DIR/$FASTA -s "Coelomomyces lativittatus" --strain $STRAIN --sbt $SBTDIR/$SBT --out $DIR/$PREFIX
#done

