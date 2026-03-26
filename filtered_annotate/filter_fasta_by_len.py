#by cassie ettinger

import sys
import Bio
from Bio import SeqIO

#python fn to remove scaffolds above a length
def filter_fasta_by_len_below(input_fasta, output_fasta, length): 
	seq_records = SeqIO.parse(input_fasta, format='fasta') #parses the fasta file
	
	#open output file ot write to
	OutputFile = open(output_fasta, 'w')
	
	for record in seq_records: 
			if len(record) < length: 
				OutputFile.write('>'+ record.id +'\n') #writes the scaffold to the file (or assession) 
				OutputFile.write(str(record.seq)+'\n') #writes the seq to the file
			
	OutputFile.close()

#python fn to remove scaffolds below a length
def filter_fasta_by_len_above(input_fasta, output_fasta, length): 
	seq_records = SeqIO.parse(input_fasta, format='fasta') #parses the fasta file
	
	#open output file ot write to
	OutputFile = open(output_fasta, 'w')
	
	for record in seq_records: 
			if len(record) >= length: 
				OutputFile.write('>'+ record.id +'\n') #writes the scaffold to the file (or assession) 
				OutputFile.write(str(record.seq)+'\n') #writes the seq to the file
			
	OutputFile.close()



filter_fasta_by_len_below("Caulerpa_lentillifera_spades.ragtag.scaffolds.fa", "Caulerpa_lentillifera_spades.ragtag.scaffolds.removed5000.fa", 5000)
filter_fasta_by_len_above("Caulerpa_lentillifera_spades.ragtag.scaffolds.fa", "Caulerpa_lentillifera_spades.ragtag.scaffolds.kept5000.fa", 5000)

filter_fasta_by_len_below("Caulerpa_racemosa_spades.ragtag.scaffolds.fa", "Caulerpa_racemosa_spades.ragtag.scaffolds.removed5000.fa", 5000)
filter_fasta_by_len_above("Caulerpa_racemosa_spades.ragtag.scaffolds.fa", "Caulerpa_racemosa_spades.ragtag.scaffolds.kept5000.fa", 5000)
