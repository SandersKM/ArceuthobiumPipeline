# Arceuthobium Pipeline
Pipeline used for genome assembly and analysis of Dwarf Mistletoe (Arceuthobium) sequences. 

### Starting data format

* All of the Arceuthobium raw Illumina sequences were in subfiles of Illumnia_Data, one subfile for each day of sequencing. 
* All raw Illumina sequences were saved as fastq.gz files. 
* For each sample, there were two raw sequencing files. One ended in "R1_001.fastq.gz" and the other ended in "R2_001.fastq.gz".
* Reference sequences are saved as .fasta files in reference_seq folder.

## TrimmFiles.sh

This script iterates over all of the files within the subfolders of Illumina_Data. For each unique sequence (checked whether it contained "R1" to eliminate duplicates), the script calls [Trimmomatic v0.36](https://www.ncbi.nlm.nih.gov/pubmed/24695404). Trimmomatic is a flexible read trimming tool for Illumina NGS data. The [parameters stipulated](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf) will cause Trimmomatic to perform the following __in this order__:
* Remove Illumina adapters provided in the TruSeq3-PE-2.fa file. Initially
Trimmomatic will look for seed matches (16 bases) allowing maximally __1__
mismatch. These seeds will be extended and clipped if in the case of paired end
reads a score of __30__ is reached (about 50 bases), or in the case of single ended reads a score of __10__, (about 17 bases).
* Scan the read with a __10__-base wide sliding window, cutting when the average quality per base drops below __20__
* Drop reads which are less than __40__ bases long after these steps

## Workflow_readDepth15_phred20.sh & filter_vcf_read_depth.py

This script takes one _parameter_: the name of the reference sequence for the assembly. First, a new subdirectory of assemblies/bwa/readDepth_15/ is created with the name of the reference sequence. For each unique trimmed sequence, 
* [BWA v0.7.17](https://www.ncbi.nlm.nih.gov/pubmed/19451168) is used to assemble the sequence files into a .sam file
* [samtools v1.9](https://www.ncbi.nlm.nih.gov/pubmed/19505943) is used convert the BWA output to a .bam file, sort the reads, compile read depts into a .tsv file, and filter by a phred quality of 20 to a .mpileup file
* [bcftools](https://samtools.github.io/bcftools/) creates concensus genotypes in a temporary .vcf file
* The python script [filter_vcf_read_depth.py](https://github.com/SandersKM/ArceuthobiumPipeline/blob/master/filter_vcf_read_depth.py) is called with .vcf file from above and direction to filter for read depth of at least 15
* [vcfutils.pl](https://github.com/lh3/samtools/blob/a80c6727c9412b00b947ace45662acc0583016e8/bcftools/vcfutils.pl) transformed the previous output into the final fasta and fastq files
* the script cleans up unneeded files and moves the final fasta, fastq, and read depth files into the output directory created at the beginning. 

The headers on each of the .fasta files are then changed to match the dirname, rather than the reference sequence name. Finally, all .fasta files are concatenated into a merged.fasta file.
