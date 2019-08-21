#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os, sys, csv, operator, re

#script to filter blast output from column in snakemake workflow kraken + blast
#only keep results with the best bitscore for each read
#remove results with score below 50 and nb mismatch above 2 

reader=csv.reader(open(sys.argv[1],"r"),delimiter="\t")
output_path=sys.argv[2]
output_path2=sys.argv[3]
#strain_filter_list=sys.argv[4]
#reader_taxid=open(sys.argv[4],"r")
#sorted_list=sorted(file, key=operator.itemgetter(5), reverse=True)			#sort by descending bitscore
#sorted_list=sorted(sorted_list, key=operator.itemgetter(0), reverse=False)	#sort by names


list_taxid_strain=[taxid.rstrip('\n') for taxid in open("taxonomy_files/taxonomy_tree_" + sys.argv[4] + ".txt",'r')]

#strain_filter=re.compile(r'\b(?:%s)\b' % '|'.join(strain_filter_list))

list_no_anthracis=set()

best_bitscore={}

with open(output_path,'wb') as out :
	writer=csv.writer(out, delimiter="\t")
	for line in reader :
		#print (line[0],line[5])
		if float(line[5]) > 50 and int(line[9]) < 3 :	#minimum blast score : 50 # max nbmismatch per reads : 2
			if line[0] not in best_bitscore :
				best_bitscore[line[0]]=float(line[5])
				writer.writerow(line)
				
			if line [0] in best_bitscore and float(line[5]) == best_bitscore[line[0]] and not line[3] in list_taxid_strain :
				list_no_anthracis.add(line[0])

for reads in list_no_anthracis:
	best_bitscore.pop(reads, None)

#keys = set(list_no_anthracis).intersection(best_bitscore)
#list_reads = {k:best_bitscore[k] for k in keys}

#print list_reads

with open(output_path2,'wb') as out : 
	
	for key in best_bitscore:
		print >>out, key	
