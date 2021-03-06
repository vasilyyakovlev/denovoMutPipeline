#! /bin/bash

mkdir -p ${tmp_folder}_varscan


java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_varscan \
-jar ${varscan} somatic \
${normal}.coordinate.srt.mpileup \
${tumor}.coordinate.srt.mpileup \
${output_dir}/${subjectID}.varscan.somatic

java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_varscan \
-jar  ${varscan} copynumber \
${normal}.coordinate.srt.mpileup \
${tumor}.coordinate.srt.mpileup \
${output_dir}/${subjectID}.varscan.copynumber

# May not need the redirect through awk
${samtools} mpileup -q 1 -f $REF ${normal}.coordinate.srt.bam ${tumor}.coordinate.srt.bam | awk 'length($5)==length($6){if ($4>0 && $7>0) print $0}' | java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_varscan -jar ${varscan} copynumber --mpileup ${tumor}

java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_varscan -jar ${varscan} copyCaller ${tumor}.copynumber --output-file ${tumor}.copynumber.called --output-homdel-file ${tumor}.copynumber.called.homdel

rmdir -p ${tmp_folder}_varscan