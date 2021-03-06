#! /bin/bash

mkdir -p ${tmp_folder}_rmdup 

# If BWA Mem is not playing well with picard, may need remove "null" mappings to get MarkDuplicates to run
#${samtools} view -h ${output_dir}/${subjectID}.fxmt.flt.clean.bam | grep -v "null" | samtools view -bS - > ${output_dir}/${subjectID}.fxmt.flt.clean2.bam

java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_rmdup \
 -jar ${picard}/MarkDuplicates.jar \
 I\=${output_dir}/${subjectID}.fxmt.bam \
 O\=${output_dir}/${subjectID}.rmdup.bam \
 M\=${output_dir}/${subjectID}.duplicate_report.txt \
 VALIDATION_STRINGENCY\=SILENT \
 REMOVE_DUPLICATES\=false

$samtools index ${output_dir}/${subjectID}.rmdup.bam

${bamtools} stats \
  -insert \
  -in ${output_dir}/${subjectID}.rmdup.bam \
  > ${output_dir}/${subjectID}.rmdup.stats

rm -rf ${tmp_folder}_rmdup