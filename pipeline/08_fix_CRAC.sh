#!/bin/bash
#SBATCH -p batch  
#SBATCH --ntasks 4 
#SBATCH --nodes 1 
#SBATCH --mem 24G 
#SBATCH --out logs/fix.%a.CRAC.log
#SBATCH -J CRAC_fix
#SBATCH --array 1
#SBATCH --time=1-0:00:00
#SBATCH --mail-type=END # notifications for job done & fail
#SBATCH --mail-user=cassande@ucr.edu # send-to address
#SBATCH -D /rhome/cassande/shared/projects/Caulerpa/annotation/


module load funannotate/1.8
source activate funannotate-1.8

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
# Set some vars

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
export PASAHOME=$(dirname  `which Launch_PASA_pipeline.pl`)
export TRINITY=$(realpath `which Trinity`)
export TRINITYHOMEPATH=$(dirname $TRINITY)
export PASACONF=$(realpath ~/pasa.config.txt)


INDIR=genomes/masked
OUTDIR=annotate
SAMPFILE=genomes/samples.csv


cut -f 1  annotate/Caulerpa_racemosa.spades.ragtag/update_results/Caulerpa_racemosa.models-need-fixing.txt | grep "CRAC" >  annotate/Caulerpa_racemosa.spades.ragtag/update_results/Caulerpa_racemosa.drop.genes.txt


funannotate fix -i  annotate/Caulerpa_racemosa.spades.ragtag/update_results/Caulerpa_racemosa.gbk -d  annotate/Caulerpa_racemosa.spades.ragtag/update_results/Caulerpa_racemosa.drop.genes.txt -t annotate/Caulerpa_racemosa.spades.ragtag/update_results/Caulerpa_racemosa.tbl
