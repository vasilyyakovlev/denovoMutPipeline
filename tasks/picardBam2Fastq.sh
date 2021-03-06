#! /bin/bash

# Strip reads from bam files with paired end reads

mkdir -p ${tmp_folder}_strip

java -Xmx${heap}m -Djava.io.tmpdir\=${tmp_folder}_strip -jar ${picard}/SamToFastq.jar I=$bampath/$bamfile/*.bam F=${output_dir}/$fastq_for_gz F2=${output_dir}/$fastq_rev_gz VALIDATION_STRINGENCY=LENIENT QUIET=true

rm -rf ${tmp_folder}_strip