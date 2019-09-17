#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os, sys, csv, operator, re

#script to filter blast output from column in snakemake workflow kraken + blast
#only keep results with the best bitscore for each read
#remove results with score below 50 and nb mismatch above 2 

reader=csv.reader(open(sys.argv[1],"r"),delimiter="\t")
writer=sys.argv[2]

list_taxid_strain=[taxid.rstrip('\n') for taxid in open("taxonomy_files/taxonomy_tree_" + sys.argv[3] + ".txt",'r')]

filter_strain_list=set()

best_bitscore={}

for line in reader :
	if float(line[5]) > 50 and int(line[9]) < 3 :	#minimum blast score : 50 # max nbmismatch per reads : 2
		if line[0] not in best_bitscore :
			best_bitscore[line[0]]=float(line[5])	
		if line [0] in best_bitscore and float(line[5]) == best_bitscore[line[0]] and not line[3] in list_taxid_strain :
			filter_strain_list.add(line[0])

for reads in filter_strain_list:
	best_bitscore.pop(reads, None)

with open(writer,'wb') as out : 	
	for key in best_bitscore:
		print >>out, key	
