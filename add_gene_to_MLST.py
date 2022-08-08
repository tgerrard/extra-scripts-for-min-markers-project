from Bio import SeqIO
from Bio import AlignIO
from Bio.SeqRecord import SeqRecord
import sys 
import re

#1st argument should be a fasta file containing the genome in which the gene you want to add is found
#2nd argument start point of gene of interest
#3rd argument end point of gene of interest
#MLST scheme should be in saved in the same directory as this script as 'arg1'_MLST.fasta
#e.g. add_gene_to_MLST.py campylobacter_43431.fasta 1738 1844

#print error for incorrect number of arguments 
if len(sys.argv) != 5:
    print("error: incorrect number of arguments")

#read in arguments
genome = sys.argv[1]

start_gene = int(sys.argv[2])

end_gene = int(sys.argv[3])

MLST_scheme = sys.argv[4]

#read in input genome
campylobacter_43431_dict = SeqIO.to_dict(SeqIO.parse(genome, "fasta"))

#read in input MLST scheme
campylobacter_43431_MLST_dict = SeqIO.to_dict(SeqIO.parse(MLST_scheme, "fasta"))

#print out full MLST scheme
MLST_scheme = (campylobacter_43431_MLST_dict["43431"].seq)

#print full genome
whole_genome = (campylobacter_43431_dict["b74042f4c3e745e4_1"].seq)

#get specified sequence from whole genome
new_gene = (campylobacter_43431_dict["b74042f4c3e745e4_1"].seq[start_gene:end_gene])

#create output
output = (MLST_scheme) + (new_gene)

stroutput = str(output)

#add line break every 60 characters
fasta_output = re.sub("(.{60})", "\\1\n", stroutput, 0, re.DOTALL)

#write final output to text file
final_fasta_output = (">43431") + "\n" + fasta_output

with open('output.txt', 'w') as f:
    f.write(final_fasta_output)











