#!/usr/bin/env python
import sys
import csv
from subprocess import call
import subprocess
import os

file_names_dmp = "/data/work/I2BC/temp_jpv/Kraken_2_test/names.dmp"
fasta_directory = '/data/work/I2BC/temp_jpv/Kraken_2_test/kraken_file_format/'
def reader_names(f_names):
	with open(f_names, "r")as f_na:
		names = csv.reader(f_na, delimiter='\t')
		taxid_dict = {}
		for row in names:
			taxid_dict[row[0]] = row[2]
	return taxid_dict


#for i in list_taxon_id:
#	call(['sed','-i',"/^>/ s/\s.*$//;/^>/ s/$/|kraken:taxid|"+taxid_kraken+"/",infile])
#for key,value in (annotation_dict.items()):
#	print(key+ ".fasta",value)
	#call(['sed','-i',"/^>/ s/\s.*$//;/^>/ s/$/|kraken:taxid|"+value+"/",(key + ".fasta")])
for row in reader_names(file_names_dmp).items():
	if os.path.isfile(str(fasta_directory) + str(row[1]) + ".fasta") == True:
		print(row[1] + ".fasta")
		call(['sed','-i',"/^>/ s/\s.*$//;/^>/ s/$/|kraken:taxid|"+row[0]+"/",fasta_directory + row[1] + ".fasta"])
		#subprocess.run('sed -i /^>/ s/\s.*$//;/^>/ s/$/|kraken:taxid|' + row[0] + "/ " + fasta_directory + row[1] + ".fasta")