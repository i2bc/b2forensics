#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import csv
import operator
import re

# script to filter blast output from column in snakemake workflow kraken + blast
# only keep results with the best bitscore for each read
# remove results with score below 50 and nb mismatch above 2

reader = csv.reader(open(sys.argv[1], "r"), delimiter="\t")
writer = sys.argv[2]
strain_filter_list = sys.argv[3]


list_taxid_strain = [taxid.rstrip('\n') for taxid in open(
    "taxonomy_files/taxonomy_tree_" + sys.argv[3] + ".txt", 'r')]

filter_strain_list = set()


best_bitscore = {}

if strain_filter_list != "hispaniensis" and strain_filter_list != "kurstaki":
	for line in reader:
		# minimum blast score : 50 # max nbmismatch per reads : 2
		if float(line[5]) > 50 and int(line[9]) < 3:
			if line[0] not in best_bitscore:
				best_bitscore[line[0]] = float(line[5])
			if line[0] in best_bitscore and float(line[5]) == best_bitscore[line[0]] and not line[3] in list_taxid_strain:
				filter_strain_list.add(line[0])

else :
	if strain_filter_list == "hispaniensis":
		strain_filter_list = ["hispaniensis", "novicida 3523"]
	elif strain_filter_list == "kurstaki":
		strain_filter_list=["kurstaki", "Bc601", "YWC2-8", "YC-10", "galleriae"]
	strain_filter = re.compile(r'\b(?:%s)\b' % '|'.join(strain_filter_list))
	for line in reader:
	# minimum blast score : 50 # max nbmismatch per reads : 2
		if float(line[5]) > 50 and int(line[9]) < 3:
			if line[0] not in best_bitscore:
				best_bitscore[line[0]] = float(line[5])
			if line[0] in best_bitscore and float(line[5]) == best_bitscore[line[0]] and not re.search((strain_filter), str((line))):
				filter_strain_list.add(line[0])

 
for reads in filter_strain_list:
	best_bitscore.pop(reads, None)

with open(writer, 'wb') as out:
	for key in best_bitscore:
		print >>out, key