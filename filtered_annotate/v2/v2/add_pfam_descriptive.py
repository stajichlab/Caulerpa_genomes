#by cassie ettinger

import sys
import Bio
from Bio import SeqIO
import csv

#python fn to add protein annotation to protein 

def add_PFAM(input_fasta, input_annot_file, pfam_key, output_fasta): 
	
	seq_records = SeqIO.parse(input_fasta, format='fasta') #parses the fasta file
	
	pfam_annot={}
	with open(pfam_key) as file:
		pfam_list = csv.reader(file, delimiter="\t")
		for line in pfam_list:
			pfam_annot[line[0]] = str(line[0] + "; " + line[1] + "; " + line[3] + "; ")
			
	pfam_dict={}
	with open(input_annot_file) as file:
		annot = csv.reader(file, delimiter="\t")
		next(annot)
		for line in annot:
			pfam=line[12]
			annotation_info=""
			if pfam != "":
			
				for family in pfam.split(";"):
					annotation_info = annotation_info + pfam_annot[family]
			
					pfam_dict[line[1]] = annotation_info
					
			else: 
				pfam_dict[line[1]] = pfam
		
	#open output file ot write to
	OutputFile = open(output_fasta, 'w')
	
	for record in seq_records: 
		OutputFile.write('>'+ record.id + "; " + str(pfam_dict[record.id]) + '\n') #writes the scaffold to the file (or assession) 
		OutputFile.write(str(record.seq)+'\n') #writes the seq to the file
	
	OutputFile.close()




add_PFAM("Caulerpa_lentillifera_v2.proteins.fa", "Caulerpa_lentillifera_spades.ragtag.annotations_v2.txt", "pfamA.tsv", "Caulerpa_lentillifera_v2.proteins_PFAM.fa")

add_PFAM("Caulerpa_racemosa_v2.proteins.fa", "Caulerpa_racemosa_spades.ragtag.annotations_v2.txt","pfamA.tsv",  "Caulerpa_racemosa_v2.proteins_PFAM.fa")

