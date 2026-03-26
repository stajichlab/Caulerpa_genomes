#!/bin/bash -l
#SBATCH --nodes 1 -c 24 -n 1 --mem 64G --out logs/annotate_function.log
# note this doesn't need that much memory EXCEPT for the XML -> tsv parsing that happens when you provided an interpro XML file

MEM=64G
module load funannotate
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
CPUS=$SLURM_CPUS_ON_NODE

if [ -z $CPUS ]; then
    CPUS=2
fi

OUTDIR=annotate

TEMPLATE=Crac.sbt
OUTDIR=annotate
BUSCODB=chlorophyta_odb10
SPECIES="Caulerpa racemosa" 

funannotate annotate --genbank Caulerpa_racemosa.gbk --cpus $CPUS  \
		--species "$SPECIES" --sbt $TEMPLATE \
	        --busco_db $BUSCODB --tmpdir $SCRATCH


