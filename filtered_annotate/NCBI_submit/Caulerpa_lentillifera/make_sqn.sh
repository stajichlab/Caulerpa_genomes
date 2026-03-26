#!/usr/bin/bash -l
#SBATCH -p short -c  2 --mem 2gb -N 1 -n 1 

module load ncbi-table2asn
table2asn -l paired-ends -l align-genus -V v -M n -c ef -i Caulerpa_lentillifera.fsa -usemt two \
	-o Caulerpa_lentillifera.sqn -Z -t Clent.sbt -euk  -j "[organism=Caulerpa lentillifera] [gcode=1]" \
	-gap-type scaffold

module load ncbi-asn_tools

asn2all -i Caulerpa_lentillifera.sqn -f d -v Caulerpa_lentillifera.aa
