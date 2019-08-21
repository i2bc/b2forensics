#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys, csv

#script to filter kraken output 
#only keep results with the best bitscore for each read
#remove results with score below 50 and nb mismatch above 2 

#reader=copen(sys.argv[1],"r"),delimiter="\t")
list_id_strain = [taxid.rstrip('\n') for taxid in open(sys.argv[1],'r')]
reader=csv.reader(open(sys.argv[2],"r"),delimiter="\t")
output_path=sys.argv[3]

with open(output_path,'w') as out :
	writer=csv.writer(out, delimiter="\t")
	for line in reader :
		if line[2] in list_id_strain:
			writer.writerow(line)	
			