#!/usr/bin/env python
import sys
from ete3 import Tree	
import csv
t = Tree("/data/work/I2BC/temp_jpv/Kraken_2_test/DendroExport_MPT_97strains.txt", format=1)

tax_number=0
namenode=0

output_nodes_dmp='/data/work/I2BC/temp_jpv/Kraken_2_test/nodes.dmp'
output_names_dmp='/data/work/I2BC/temp_jpv/Kraken_2_test/names.dmp'

for node in t.traverse("levelorder"):	
	tax_number+=1
	node.add_features(tax_id=tax_number)
	if node.children:
		if not node.name:
			namenode+=1
			node.name="synthetic_enty_" + str(namenode)
#	for i in node.children:
#		print(node.name,i.name,node.tax_id)
		
with open(output_nodes_dmp, mode='w') as nodes_file, open(output_names_dmp, mode ='w') as names_file:
	nodes_writer = csv.writer(nodes_file, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
	names_writer = csv.writer(names_file, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
	nodes_writer.writerow(['1','|','1','|','no rank','|','|','0','|','1','|','11','|','1','|','0','|','1','|','1','|','|','|','|','1','|','0','|','1','|'])
	for node in t.traverse("levelorder"):
		for i in node.children:
			nodes_writer.writerow([i.tax_id,'|',node.tax_id,'|','no rank','|','|','0','|','1','|','11','|','1','|','0','|','1','|','1','|','|','|','|','1','|','0','|','1','|'])
		names_writer.writerow([node.tax_id,'|',node.name,'|','\t','|','scientific name','|'])


#print (t.get_ascii(show_internal=True))
