#by cassie ettinger

import sys
import Bio
from Bio import SeqIO
import csv

#python fn to add protein annotation to protein 

def add_PFAM(input_fasta, input_annot_file, output_fasta): 
	
	seq_records = SeqIO.parse(input_fasta, format='fasta') #parses the fasta file
	
	pfam_dict={}
	with open(input_annot_file) as file:
		annot = csv.reader(file, delimiter="\t")
		for line in annot:
			pfam_dict[line[1]] = line[12]
		
	#open output file ot write to
	OutputFile = open(output_fasta, 'w')
	
	for record in seq_records: 
		OutputFile.write('>'+ record.id + " " + str(pfam_dict[record.id]) + '\n') #writes the scaffold to the file (or assession) 
		OutputFile.write(str(record.seq)+'\n') #writes the seq to the file
	
	OutputFile.close()




add_PFAM("Caulerpa_lentillifera_v2.proteins.fa", "Caulerpa_lentillifera_spades.ragtag.annotations_filt.txt", "Caulerpa_lentillifera_v2.proteins_PFAM.fa")

add_PFAM("Caulerpa_racemosa_v2.proteins.fa", "Caulerpa_racemosa_spades.ragtag.annotations_filt.txt", "Caulerpa_racemosa_v2.proteins_PFAM.fa")
