#Trimming bad quality region of the reads 
echo Trimming using Fastp pre-processor
out1=QT_R1.fq.gz
out2=QT_R2.fq.gz
name=8C.fasta
name2=polish8C.fasta
fastp -i $1 -I $2 -o $out1 -O $out2 -w 3 /
echo SPAdes assembly
-w 16 -h report.html -j fastp8C.json -t 1 -T 1
spades.py -k 21,31,41,51,61,71,81,91,101,111,121,127 -t 8 -1 $out1 -2 $out2 -o SPAdes8C_dir --careful &
echo Unicycler assembly
unicycler -1 $out1 -2 $out2 -o Uni8C_dir -t4
cp Uni8C_dir/assembly.fasta $name
#mapping and convert sam to bam
bwa index -a is $name
bwa mem $name $out1 $out2 > out.sam
samtools sort -@ 3 out.sam > ${name%.fasta}.bam
rm out.sam
samtools index ${name%.fasta}.bam
#pilon assembly
pilon --genome $name --frags ${name%.fasta}.bam --outdir pilon1st --changes --threads 8
cp pilon1st/pilon.fasta $name2
bwa index -a is $name2
bwa mem $name2 $out1 $out2 >out.sam
samtools sort -@ 3 out.sam > ${name2%.fasta}.bam
rm out.sam
samtools index ${name2%.fasta}.bam
#IGV command
-igv -g $name2 ${name2%.fasta}.bam



