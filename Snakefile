shell.executable("/bin/bash")
from os.path import join

# read config info into this namespace
configfile: "config.yaml"

DATA_PATH=config['data_path']
KRAKEN_DB_PATH=config['kraken_dp_path']
BLAST_DB_PATH=config['blast_db_path']
SAMPLES=config['samples']
STRAINS=config["strains"]
STRANDS=["R1","R2"]

rule all:
	input:
		expand("reference_genomes/{strain}_genome.fa.amb",strain=STRAINS),
		expand("reference_genomes/{strain}_genome.fa.fai",strain=STRAINS),		
		expand("b2forensics_results/kraken_results/{sample}_cdb_paired.txt",sample=SAMPLES),
		expand("b2forensics_results/kraken_results/{sample}_cdb_paired.txt",sample=SAMPLES),
		expand("b2forensics_results/megablast_results/{sample}_{strain}_blast_output_{strand}_filtered.txt",strain=STRAINS,strand=STRANDS,sample=SAMPLES),
		expand("b2forensics_results/blast_reads_id/{sample}_{strain}_blast_output_uniq.txt",strain=STRAINS,sample=SAMPLES),
		expand("b2forensics_results/krona_results/{sample}.html",sample=SAMPLES)

# index of reference fasta and silva sequences (subunit ribosomal RNA)
rule bwa_index_ref:
	input:
		"reference_genomes/{strain}_genome.fa"
	output:
		"reference_genomes/{strain}_genome.fa.amb",
		"reference_genomes/{strain}_genome.fa.ann",
		"reference_genomes/{strain}_genome.fa.bwt",
		"reference_genomes/{strain}_genome.fa.pac",
		"reference_genomes/{strain}_genome.fa.sa"
	conda:
		"envs/genomic.yaml"
	threads:1
	params:
		mem=32,
		jobname="bwa_index"
	shell :
		"bwa index {input}"

# index of ref fasta with samtools:
rule samtools_index_ref:
	input:
		"reference_genomes/{strain}_genome.fa"
	output:
		"reference_genomes/{strain}_genome.fa.fai"
	threads:1
	params:
		mem=32,
		jobname="samtools_index"
	shell :
		"samtools faidx {input}"		

# index of silva sequences (subunit ribosomal RNA)
rule bwa_index_silva:
	input:
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa"
	output:
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa.amb",
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa.ann",
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa.bwt",
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa.pac",
		"tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa.sa"
	threads:1
	params:
		mem=32,
		jobname="bwa_index"
	shell :
		"bwa index {input}"


# kraken paired analyse with custom database
rule kraken2_paired:
	input:
		kdb=KRAKEN_DB_PATH,
		fv=join(DATA_PATH,"{sample}_R1.fastq.gz"),
		rv=join(DATA_PATH,"{sample}_R2.fastq.gz") 					
	output:
		protected("b2forensics_results/kraken_results/{sample}_cdb_paired.txt")
	threads:16
	shell:
		"kraken2 --db {input.kdb} --gzip-compressed --paired --threads {threads} --output {output} {input.fv} {input.rv}"

# krona representation of kraken results
rule krona:
	input:
		"b2forensics_results/kraken_results/{sample}_cdb_paired.txt"
	output:
		"b2forensics_results/krona_results/{sample}.html"
	conda:
		"envs/genomic.yaml"
	threads:1
	params:
		mem=60,
		jobname="krona.{sample}"
	shell:
		"ktImportTaxonomy {input} -o {output} -q 2 -t 3 -k "

# get reads_id for reads (paired end) identified as species of interest
rule get_paired_reads_id:
	input:
		tax="taxonomy_files/taxonomy_tree_{strain}.txt",
		kraken="b2forensics_results/kraken_results/{sample}_cdb_paired.txt"
	output:
		"b2forensics_results/kraken_reads_id/{sample}_kraken_paired_{strain}.txt"
	threads:1	
	shell:
		"scripts/kraken_filter.py {input.tax} {input.kraken} {output}"

# prepare files for seqtk:
rule prepare_seqtk:
	input:
		"b2forensics_results/kraken_reads_id/{sample}_kraken_paired_{strain}.txt"
	output:
		"b2forensics_results/kraken_reads_id/{sample}_kraken_paired_reads_id_{strain}.txt"
	threads:1	
	shell:
		"cut -f2 {input} | sort > {output}"


# get fastq from paired reads id
rule subseq_paired:
	input:
		reads=join(DATA_PATH,"{sample}_{strand}.fastq.gz"),
		reads_id="b2forensics_results/kraken_reads_id/{sample}_kraken_paired_reads_id_{strain}.txt"
	output:
		"b2forensics_results/kraken_fastq/{sample}_{strain}_{strand,(R1|R2)}.fq"
	threads:1
	shell:
		"seqtk subseq {input.reads} {input.reads_id} > {output}"

# compression of fastq
rule compression_into_gzip3:
	input: 
		"b2forensics_results/kraken_fastq/{sample}.fq"
	output:
		protected("b2forensics_results/kraken_fastq/{sample}.fq.gz")
	threads:6
	shell:
		"pigz -9 -p {threads} {input}"

# rDNA_depletion and tRNA depletion 

rule bwa_map_trDNA:
	input :
		ref="tRNA_sequences/tRNA_bacteria_with_silva-128_lsu_ssu.fa",
		r1="b2forensics_results/kraken_fastq/{sample}_R1.fq.gz",
		r2="b2forensics_results/kraken_fastq/{sample}_R2.fq.gz"
	output:
		temp("b2forensics_results/trDNA_depleted/{sample}.sorted.bam")
	conda:
		"envs/genomic.yaml"
	threads: 6
	shell:
		"bwa mem -M -t {threads} {input.ref} {input.r1} {input.r2} | "
		"samtools view -@ {threads} -Sb | "
		"samtools sort -n -o {output}"



rule extract_trDNA_depleted_reads:
	input:
		"b2forensics_results/trDNA_depleted/{sample}.sorted.bam"
	output:
		ffastq=temp("b2forensics_results/trDNA_depleted/{sample}_trDNA_depleted_R1.fq.gz"),
		rfastq=temp("b2forensics_results/trDNA_depleted/{sample}_trDNA_depleted_R2.fq.gz"),
		sfastq=temp("b2forensics_results/trDNA_depleted/{sample}_trDNA_depleted_single.fq.gz")
	threads:6
	shell:
		"samtools bam2fq -@ {threads} -f4 {input} -1 {output.ffastq} -2 {output.rfastq} -s {output.sfastq} -n -c 9"

# mapping of paired-end reads (both mates identified as species of interest)
rule bwa_map_ref:
	input :
		ref="reference_genomes/{strain}_genome.fa",
		index="reference_genomes/{strain}_genome.fa.amb",
		r1="b2forensics_results/trDNA_depleted/{sample}_{strain}_trDNA_depleted_R1.fq.gz",
		r2="b2forensics_results/trDNA_depleted/{sample}_{strain}_trDNA_depleted_R2.fq.gz"
	output:
		temp("b2forensics_results/trDNA_depleted/blast_alignment_{strain}/{sample}_aln_paired_trDNA_depleted_{strain}.bam")
	threads:6
	shell:
		"(bwa mem -M -t {threads} {input.ref} {input.r1} {input.r2} | samclip --ref {input.ref} | "
		"samtools view -q 25 -@ {threads} -Sb -o {output})" #on ne garde pas les reads avec plus d'un mismatch | grep NM:i:[0-1] -w 

rule fixmate:
	input:
		"b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.bam"
	output:
		temp("b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.fixed.bam")
	threads:6
	shell:
		"samtools fixmate -r {input} {output}"

rule sorting:
	input:
		"b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.fixed.bam"
	output:
		protected("b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.sorted.bam")
	threads:6
	shell:
		"samtools sort -@ threads {input} -o {output}"

rule index:
	input:
		"b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.sorted.bam"
	output:
		"b2forensics_results/trDNA_depleted/{tool}_alignment_{strain}/{sample}.sorted.bam.bai"
	threads:6
	shell:
		"samtools index {input}"

# get reads_id for reads (paired end) identified as species of interest
rule get_paired_reads_id2:
	input:
		"b2forensics_results/trDNA_depleted/blast_alignment_{strain}/{sample}_aln_paired_trDNA_depleted_{strain}.sorted.bam"
	output:
		"b2forensics_results/alignment_reads_id/{sample}_alignment_paired_reads_id_{strain}.txt"
	threads:6
	shell:
		"samtools view -@ {threads} -q 60 -f2 {input} | egrep 'NC_005707|NC_007322|NC_007323|NZ_CP018094|NZ_CP015151|NZ_CP015152|NZ_CP015153|NZ_CP015154|NZ_CP015155|NZ_CP015156|NC_003131|NC_003132|NC_003134' -v| grep NM:i:[0-2] -w | cut -f1 | sort | uniq -d > {output} || true" #on ne garde pas les reads avec plus d'un mismatch | grep NM:i:[2-9] -v  

# get fastq from paired reads id
rule subseq_paired2:
	input:
		reads="b2forensics_results/kraken_fastq/{sample}_{strain}_{strand}.fq.gz",
		reads_id="b2forensics_results/alignment_reads_id/{sample}_alignment_paired_reads_id_{strain}.txt"
	output:
		"b2forensics_results/alignment_fastq/{sample}_{strain}_{strand}.fq"
	threads:1
	shell:
		"seqtk subseq {input.reads} {input.reads_id} > {output}"

# compression of fastq
rule compression_into_gzip4:
	input: 
		"b2forensics_results/alignment_fastq/{sample}.fq"
	output:
		protected("b2forensics_results/alignment_fastq/{sample}.fq.gz")
	threads:6
	shell:
		"pigz -9 -p {threads} {input}"

#fastq conversion into fasta
rule fq_to_fa:
	input:
		"b2forensics_results/alignment_fastq/{sample}.fq.gz"
	output:
		"b2forensics_results/kraken_fasta/{sample}.fa"
	threads:1
	shell:
		"seqtk seq -A {input} > {output}"

# megablast on fasta (reads identified as species of interest by kraken)
rule megablast:
	input:
		"b2forensics_results/kraken_fasta/{sample}_{strand}.fa"
	output:
		protected("b2forensics_results/megablast_results/{sample}_blast_output_{strand}.txt")
	threads:16
	shell:
		"blastn -db " + BLAST_DB_PATH + " -num_threads {threads} -max_target_seqs 100 -query {input} -out {output} -perc_identity 95 -qcov_hsp_perc 90 "
		"-outfmt '6 qseqid sacc stitle staxid score bitscore evalue pident nident mismatch qcovhsp'"

# filter blast output to keep best bitscore results with a least a bitscore of 50 and at most 2 SNP
rule script_blast_output:
	input:
		"b2forensics_results/megablast_results/{sample}_{strain}_blast_output_{strand}.txt"
	output:
		"b2forensics_results/megablast_results/{sample}_{strain}_blast_output_{strand}_filtered.txt"
	threads:1
	shell:
		"python2 scripts/blast_filter.py {input} {output} {wildcards.strain}"

# extract reads id identified as species of interest from blast results
rule blast_reads_id:
	input:
		r1="b2forensics_results/megablast_results/{sample}_{strain}_blast_output_R1_filtered.txt",
		r2="b2forensics_results/megablast_results/{sample}_{strain}_blast_output_R2_filtered.txt"
	output:
		"b2forensics_results/blast_reads_id/{sample}_{strain}_blast_output_uniq.txt"
	threads:1
	shell:
		"cat {input.r1} {input.r2} | sort | uniq > {output}"


