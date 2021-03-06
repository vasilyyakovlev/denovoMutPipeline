#! /bin/bash

echo "align first batch"
$bwa aln -l 30 -t $CPUs $hg19_ref_bwa ${output_dir}/$fastq_for_gz > ${output_dir}/${subjectID}_fastq1.sai 2> ${output_dir}/${subjectID}_fastq1.log

echo "align second batch"
$bwa aln -l 30 -t $CPUs $hg19_ref_bwa ${output_dir}/$fastq_rev_gz > ${output_dir}/${subjectID}_fastq2.sai 2> ${output_dir}/${subjectID}_fastq2.log

echo "pe alignment "
$bwa sampe  $hg19_ref_bwa ${output_dir}/${subjectID}_fastq1.sai ${output_dir}/${subjectID}_fastq2.sai ${output_dir}/$fastq_for_gz ${output_dir}/$fastq_rev_gz | gzip > ${output_dir}/${subjectID}.sam.gz 
2> ${output_dir}/${subjectID}.pe.log

${samtools} view -uS ${output_dir}/${subjectID}.sam.gz |  ${samtools} sort -m 3000000000 - ${output_dir}/${subjectID}.srt

${samtools} index ${PWDS}/${subjectID}.srt.bam

${bamtools} stats -insert -in ${output_dir}/${subjectID}.srt.bam > ${output_dir}/${subjectID}.srt.stats

