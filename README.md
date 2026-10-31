# ARG-MGE-Metagenomics-Pipeline
A reproducible Snakemake-based metagenomic workflow for the identification of antimicrobial resistance genes (ARGs) and their association with mobile genetic elements (MGEs) in metagenomic datasets. The pipeline starts from NCBI SRA accessions, performs quality control and metagenome assembly, identifies ARG-containing contigs, and characterizes their mobility using CARD-RGI, geNomad, and MobileElementFinder.

### Features
- Automatic download of sequencing data from NCBI SRA
- Read quality assessment with FastQC
- Read trimming with FastP
- Metagenome assembly using MEGAHIT
- Assembly assessment with QUAST
- ARG detection using CARD-RGI
- Conversion of ARG coordinates to BED format
- Extraction of ARG-containing contigs using SeqTK
- Viral and plasmid prediction using geNomad
- Mobile element prediction using MobileElementFinder
- Read mapping with Minimap2
- BAM sorting and indexing with Samtools
- Runtime monitoring and logging
- Conda-based reproducibility

Workflow
---------------
1. NCBI SRA -> SRA Toolkit -> FASTQ
2. FastQC (raw) -> FastP -> FastQC (trimmed)
3. MEGAHIT -> QUAST
4. RGI
  1. BED Conversion
  2. ARG Contig List
  3. SeqTK Extraction -> ARG_Contigs.fa
      1. MobileElementFinder
      2. geNomad
5. Minimap2 -> Samtools

Installation
---------------
### Clone repository
```sh
git clone https://github.com/victordzikunu/ARG-MGE-Metagenomics-Pipeline.git

cd capstone-pipeline
```

### Create Snakemake enviroment
```sh
conda create \
  -n snakemake \
  -c conda-forge \
  -c bioconda \
  snakemake

conda activate snakemake
```

Database Setup
---------------
### Create database directory
```sh
mkdir -p resources/CARD
mkdir -p resources/genomad_db
mkdir -p resources/MEFinderDB
```

### CARD Database
Create RGI enviroment and activate:
```sh
#Create enviroment
conda create \
  -n rgi \
  -c conda-forge \
  -c bioconda \
  rgi
#activate enviroment
conda activate rgi
```

Download CARD:
```sh
cd resources/CARD

rgi clean --local

wget https://card.mcmaster.ca/latest/data

tar -xvf data ./card.json

rgi load --card_json card.json --local

cd ../..
```

### geNomad Database
Create and activate a geNomad enviroment:
```sh
#Create enviroment
conda create \
  -n genomad \
  -c conda-forge \
  -c bioconda \
  genomad
#activate enviroment
conda activate genomad
```

Download the database:
```sh
genomad download-database .
```

This will create the database in `genomad_db` directory

### MobileElementFinder Database
Install the database using the instructions found in MobileElementFinder documentation: https://pypi.org/project/MobileElementFinder/

After installation place the database files in `resources/MEFinderDB/`
