# loops through all of the file names in these folder
for f in $(ls Illumina_Data/*/* ); do
	# Only takes the file that ends with _R1... as base text
        if [[ "${f}" == *"_R1"* ]] ;then
	# call trimmomatic on sequences
		echo "Filtering adapter sequences..."
		echo `basename " ${f%%_R1*}"`
		jdk-11.0.2/bin/java -classpath Trimmomatic-0.36/trimmomatic-0.36.jar org.usadellab.trimmomatic.TrimmomaticPE ${f%%_R1*}_R1_001.fastq.gz ${f%%_R1*}_R2_001.fastq.gz -baseout TrimmedSeq/`basename "${f%%_R1*}"`.fq.gz ILLUMINACLIP:Trimmomatic-0.36/adapters/TruSeq3-PE-2.fa:1:30:10 SLIDINGWINDOW:10:20 MINLEN:40
	fi
done

