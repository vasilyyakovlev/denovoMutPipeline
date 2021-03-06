#! /bin/bash

mkdir -p ${tmp_folder}_fixmate 

#java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_fixmate -jar ${picard}/ValidateSamFile.jar INPUT\=${output_dir}/${subjectID}.srt.bam OUTPUT\=${output_dir}/${subjectID}.valid.srt.bam 

echo "Fixing mate pairs"
java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_fixmate -jar ${picard}/FixMateInformation.jar INPUT\=${output_dir}/${subjectID}.srt.bam OUTPUT\=${output_dir}/${subjectID}.fxmt.bam SO\=coordinate CREATE_INDEX\=true VALIDATION_STRINGENCY\=SILENT

${bamtools} stats -insert -in ${output_dir}/${subjectID}.fxmt.bam > ${output_dir}/${subjectID}.fxmt.stats

rm -rf ${tmp_folder}_fixmate

