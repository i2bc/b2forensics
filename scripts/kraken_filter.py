#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys, csv

#script to filter kraken output 
#only keep results with a taxid include in the list_id_strain (in taxonomy_files)

list_id_strain = [taxid.rstrip('\n') for taxid in open(sys.argv[1],'r')]
reader=csv.reader(open(sys.argv[2],"r"),delimiter="\t")
output_path=sys.argv[3]

with open(output_path,'w') as out :
	writer=csv.writer(out, delimiter="\t")
	for line in reader :
		if line[2] in list_id_strain:
			writer.writerow(line)	
			
