# b2forensics

**Contacts**

Gilles Vergnaud (<gilles.vergnaud@u-psud.fr>)
Jean-Philippe Vernadet (<jean-philippe.vernadet@laposte.net>)

## Installation

### Softwares/Scripts

* Kraken2
 
```bash
# Clone or download files
git clone https://github.com/DerrickWood/kraken2.git
```

```bash
# Launch install script 
./install_kraken2.sh $KRAKEN2_DIR
```
More details in the [manual of Kraken2].

* Conda

```bash
# Get miniconda 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh;
./Miniconda3-latest-Linux-x86_64.sh
```

* b2forensics environment and scripts
```bash
# Clone or download files
git clone https://github.com/i2bc/b2forensics.git
```

### Database/Data

The first part of the pipeline uses a Kraken2 custom or standard database, a file with tRNA sequences and subunit ribosomal RNA sequences, and files of reference genomes of the species of interest.  

* Kraken2 database

```bash
# standard database
kraken2-build --standard --db $DBNAME
```
As mentioned in the [manual of Kraken2], it is possible to create a custom database, view this manual or go to Example section. 

* tRNA sequences/subunit ribosomal sequences
tRNA sequences are from [tRNAdb], subunit ribosomal RNA sequences are from [silva database].
Concatenate these files and put it in tRNA_sequences directory.

* reference genomes
Download genomes fasta files of the species of interest and put in reference_genomes directory. 

* taxonomic IDs
Make a file containing a list, one for each species of interest, with all taxonomic IDs you would like to include (one per line).

### Scripts

### Example

### How to use

[manual of Kraken2]: https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown
[tRNAdb]: http://trna.bioinf.uni-leipzig.de/DataOutput/Welcome
[silva database]: https://www.arb-silva.de/no_cache/download/archive