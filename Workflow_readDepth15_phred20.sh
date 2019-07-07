#!/bin/bash
# Header should have sequence name and reference name
mkdir assemblies/bwa/readDepth_15/${1}
output_dir="assemblies/bwa/readDepth_15/${1}/" 
ref="reference_seq/${1}.fasta"
# loops through all of the file names in these folder
for f in $(ls TrimmedSeq/*); do
    # Only takes the file that ends with _1P... as base text
	if [[ "${f}" == *"_1P"* ]] ;then
		# call trimmomatic on sequences
		index=`basename "${f%%_1P*}"`
		echo `basename "${f%%_1P*}"`
		echo ${ref}
		#Starts with trimmed sequences
		gunzip ${f%%_1P*}_1P.fq.gz
		gunzip ${f%%_1P*}_2P.fq.gz
 
		echo "Creating BWA index..."
		#index = ITS.fasta replace this with gene that we want 
		bwa-0.7.17/bwa index ${ref}
		echo "Mapping reads with bwa..." #change reference sequence and indices in TrimmedSeq
		#first is reference, second is trimmed sequence 1P, 
		#third is trimmed sequence 2P, file after > is file to 
		#create/write to
		bwa-0.7.17/bwa mem ${ref} ${f%%_1P*}_1P.fq ${f%%_1P*}_2P.fq > ${index}.sam
		#rezip things
		gzip ${f%%_1P*}_1P.fq
		gzip ${f%%_1P*}_2P.fq
		#last file created is always an input
		echo "Coverting SAM to BAM..."
		samtools/bin/samtools view -bS ${index}.sam > ${index}.bam
		echo "Sorting reads..."
		samtools/bin/samtools sort ${index}.bam -o ${index}_sorted.bam
		echo "Determining read depth..."
		samtools/bin/samtools depth ${index}_sorted.bam > ${index}_read_depth.tsv
		echo "Making BAM pileup, filtering by phred quality 20..."
		samtools/bin/samtools mpileup -Q 20 -Agf $ref ${index}_sorted.bam > ${index}.mpilup
		echo "Generating consensus genotypes..."
		bcftools/bcftools call -c ${index}.mpilup > ${index}_temp.vcf
		echo "Filtering for read depth >= 15..."
		python filter_vcf_read_depth.py ${index}_temp.vcf 15
		echo "Generating final FASTA sequence..."
		perl vcfutils.pl vcf2fq ${index}_temp.vcf.filtered  > ${index}.fastq
		seqtk/seqtk seq -A ${index}.fastq > ${index}.fasta
		echo "Cleaning up..."
		# removes junk stuff, not sure what we want to keep or 
		# remove, go wild
		mkdir ${output_dir}${index}
		rm ${index}_temp.vcf ${index}_temp.vcf.filtered ${index}.mpilup
		rm ${index}_sorted.bam ${index}.bam ${index}.sam
		mv ${index}.fasta ${index}.fastq ${index}_read_depth.tsv ${output_dir}${index}
	fi 
done
# changes header on FASTA File to match dir name, not refseq
cd ${output_dir}
for dirname in */; do
	(cd "$dirname" && for i in *.fasta; do sed -i "1s/.*/>${i%.fasta}/" $i; done)
done
# Concatenate FASTA files into merged.fasta
mkdir all_fasta 
for d in */; do
        plugin=$(basename $d)
        [[ $plugin =~ ^(all_fasta)$ ]] && continue
	cp $plugin/$plugin.fasta all_fasta
done 
cat all_fasta/* > merged.fasta
