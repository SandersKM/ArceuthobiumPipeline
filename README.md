# Arceuthobium Pipeline
Pipeline used for genome assembly and analysis of Dwarf Mistletoe (Arceuthobium) sequences. 

### Starting data format

* All of the Arceuthobium raw Illumina sequences were in subfiles of Illumnia_Data, one subfile for each day of sequencing. 
* All raw Illumina sequences were saved as fastq.gz files. 
* For each sample, there were two raw sequencing files. One ended in "R1_001.fastq.gz" and the other ended in "R2_001.fastq.gz".

## TrimmFiles.sh

This script iterates over all of the files within the subfolders of Illumina_Data. For each unique sequence (checked whether it contained "R1" to eliminate duplicates), the script calls [Trimmomatic v0.36](https://www.ncbi.nlm.nih.gov/pubmed/24695404). Trimmomatic is a flexible read trimming tool for Illumina NGS data. The [parameters stipulated](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf) will cause Trimmomatic to perform the following __in this order__:

* Remove Illumina adapters provided in the TruSeq3-PE-2.fa file. Initially
Trimmomatic will look for seed matches (16 bases) allowing maximally __1__
mismatch. These seeds will be extended and clipped if in the case of paired end
reads a score of __30__ is reached (about 50 bases), or in the case of single ended reads a score of __10__, (about 17 bases).
* Scan the read with a __10__-base wide sliding window, cutting when the average quality per base drops below __20__
* Drop reads which are less than __40__ bases long after these steps
