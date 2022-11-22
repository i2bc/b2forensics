# b2forensics


**Contacts**

- Gilles Vergnaud (<gilles.vergnaud@u-psud.fr>)
- Jean-Philippe Vernadet (<jean-philippe.vernadet@laposte.net>)

## Installation

### Softwares/Scripts

* Kraken2
 
```bash
# clone or download files
git clone https://github.com/DerrickWood/kraken2.git
```

```bash
# launch install script 
./install_kraken2.sh $KRAKEN2_DIR
```
More details in the [manual of Kraken2].

* Conda

```bash
# get miniconda 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh;
./Miniconda3-latest-Linux-x86_64.sh
```

* b2forensics environment and scripts
```bash
# clone or download files
git clone https://github.com/i2bc/b2forensics.git
```




### Database/Data

The first part of the pipeline uses a Kraken2 custom or standard database, a file with tRNA sequences and subunit ribosomal RNA sequences, and files of reference genomes of the species of interest.  

* Kraken2 database

```bash
# standard database
kraken2-build --standard --db $DBNAME
```
As mentioned in the [manual of Kraken2], it is possible to create a custom database, view this manual or go to How to use section. 

* BLAST database
The pipeline needs a local BLAST database. Do not forget to indicate the BLAST database PATH in the config file.
As explained on the "[Get NCBI BLAST databases]" page, it is possible to download a preformatted NCBI BLAST database.
Use the script "update_blastdb.pl" from a [blast+ package]

* tRNA sequences/subunit ribosomal sequences
tRNA sequences are from [tRNAdb], subunit ribosomal RNA sequences are from [silva database]. 
Concatenate these files and put it in tRNA_sequences directory.

* reference genomes
Download genomes fasta files of the species of interest and put in reference_genomes directory. 

* taxonomic IDs
Make a file containing a list, one for each species of interest, with all taxonomic IDs you would like to include (one per line), and put it in taxonomy_files directory.

## How to use

In data directory, you have a dataset to test the pipeline. With this pipeline, we will search for sequences that could be assigned to a taxid (*Bacillus anthracis* and sub taxid) from the list in the file [taxonomy_files/taxonomy_tree_anthracis.txt]. 

* BLAST database
Just use the script "update_blastdb.pl" from a [blast+ package].

* tRNA sequences/subunit ribosomal sequences
Get Bacteria tRNA genes sequences from tRNAdb with [this request]. Get [SILVA_128_LSURef_tax_silva.fasta.gz and SILVA_128_SSURef_Nr99_tax_silva.fasta.gz] from silva database.
Concatenate these files (unzipped) and put it in tRNA_sequences directory in a file "tRNA_bacteria_with_silva-128_lsu_ssu.fa".

* Kraken2 database

To create Kraken2 database, download fastas for assemblies "Complete Genome" for bacteria, archaea, fungi, protozoa, virus.
We can use scripts from Mick Watson
```bash
# clone the git repo
git clone https://github.com/mw55309/Kraken_db_install_scripts.git
```
As explained in [opiniomics post] and with adjustment for kraken2

```bash
# run for each branch of life you wish to download
perl download_bacteria.pl
perl download_archaea.pl
perl download_fungi.pl
perl download_protozoa.pl
perl download_viral.pl
```

```bash
# build a new database 
# download taxonomy
kraken2-build --download-taxonomy --db kraken2_db
```
```bash
# for each branch, add all fna in the directory to the database
for dir in fungi protozoa archaea viral bacteria; do
        for fna in `ls $dir/*.fna`; do
                kraken2-build --add-to-library $fna --db kraken2_db
        done
done
```
```bash
# build the database
kraken2-build --build --db kraken2_db
```
* fill in the different paths in the [config file]

## Results/output files

### Structure of the output directory


```
├── b2forensics_results
    ├── alignment_fastq
    |	├── {sample}_{strain}_R1.fq.gz 	
    |	├── {sample}_{strain}_R2.fq.gz
    ├── alignment_reads_id 
    |	├── {sample}_alignment_paired_reads_id_{strain}.txt
    ├── blast_reads_id
    |	├── {sample}_{strain}_blast_output_uniq.txt
    ├── kraken_fasta
    |	├── {sample}_{strain}_R1.fa
    |	├── {sample}_{strain}_R2.fa
    ├── kraken_fastq
    |	├── {sample}_{strain}_R1.fq.gz 	
    |	├── {sample}_{strain}_R2.fq.gz
    ├── kraken_reads_id
    |	├── {sample}_kraken_paired_reads_id_{strain}.txt
    ├── kraken_results
    |	├── {sample}_cdb_paired.txt 
    ├── megablast_results
    |	├── {sample}_{strain}_blast_output_R1.txt
    |	├── {sample}_{strain}_blast_output_R2.txt
    |	├── {sample}_{strain}_blast_output_R1_filtered.txt
    |	├── {sample}_{strain}_blast_output_R2_filtered.txt
    ├── trDNA_depleted
    	├── blast_alignment_{strain}
    		├── {sample}_aln_paired_trDNA_depleted_{strain}.sorted.bam
```


[manual of Kraken2]: https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown
[blast+ package]: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+
[Get NCBI BLAST databases]: https://www.ncbi.nlm.nih.gov/books/NBK537770
[tRNAdb]: http://trna.bioinf.uni-leipzig.de/DataOutput/Welcome
[silva database]: https://www.arb-silva.de/no_cache/download/archive
[taxonomy_files/taxonomy_tree_anthracis.txt]: https://github.com/i2bc/b2forensics/blob/master/taxonomy_files/taxonomy_tree_anthracis.txt
[this request]: http://trna.bioinf.uni-leipzig.de/DataOutput/Search?vOrg=Bacteria&vTax=2
[SILVA_128_LSURef_tax_silva.fasta.gz and SILVA_128_SSURef_Nr99_tax_silva.fasta.gz]: https://www.arb-silva.de/no_cache/download/archive/release_128/Exports
[opiniomics post]: http://www.opiniomics.org/building-a-kraken-database-with-new-ftp-structure-and-no-gi-numbers/
[config file]: https://github.com/i2bc/b2forensics/blob/master/config.yaml
