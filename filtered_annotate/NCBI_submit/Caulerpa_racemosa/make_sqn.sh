#!/usr/bin/bash -l
#SBATCH -p short -c  2 --mem 2gb -N 1 -n 1 

module load ncbi-table2asn
table2asn -l paired-ends -l align-genus -V v -M n -c efx -i Caulerpa_racemosa.fsa -usemt two \
	-o Caulerpa_racemosa.sqn -Z -t Crac.sbt -euk  -j "[organism=Caulerpa racemosa] [gcode=1]" \
	-gap-type scaffold

module load ncbi-asn_tools

asn2all -i Caulerpa_racemosa.sqn -f d -v Caulerpa_racemosa.aa
