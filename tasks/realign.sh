#! /bin/bash

mkdir -p ${tmp_folder}_realign

java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_realign \
 -jar $gatk \
 -I $1 \
 -R $REF \
 -T IndelRealigner \
 -targetIntervals ${output_dir}/${subjectID}.forRealign.intervals \
 --out ${output_dir}/${subjectID}.realigned.bam \
 -known $DBSNP  \
 -LOD 0.4  \
 -compress 5 \
 -l INFO  \
 -L $ExonFile

mkdir -p ${tmp_folder}_realign

${bamtools} stats -insert -in ${output_dir}/${subjectID}.realigned.bam > ${output_dir}/${subjectID}.realigned.stats