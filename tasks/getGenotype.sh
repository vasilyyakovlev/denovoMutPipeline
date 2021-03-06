#! /bin/bash

java -Xmx${heap}m  \
   -jar $gatk \
   -R $REF \
   -T UnifiedGenotyper \
   --dbsnp $DBSNP \
   -I ${output_dir}/${subjectID}.realigned.recal.bam \
   -o ${output_dir}/${subjectID}.snps.raw.all.vcf \
   -stand_call_conf 30.0 \
   -stand_emit_conf 10.0 \
   -l INFO \
   -dcov 200 \
   -L $ExonFile \
   -glm SNP  \
   -nt 1  \
   --output_mode EMIT_ALL_CONFIDENT_SITES
#   -A HaplotypeScore \
#   -A InbreedingCoeff \
#   -U ALLOW_UNINDEXED_BAM \

java -Xmx${heap}m  \
 -jar $gatk \
 -T VariantFiltration \
 -R $REF \
 -o ${output_dir}/${subjectID}.snps.all.vcf \
 --variant ${output_dir}/${subjectID}.snps.raw.all.vcf \
 --mask ${output_dir}/variants/${subjectID}.indels.PASS.vcf \
 --maskName InDel \
 --filterExpression "QD < 2.0" \
 --filterName "QDFilter" \
 --filterExpression "MQ < 40.0" \
 --filterName "MQFilter" \
 --filterExpression "FS > 60.0" \
 --filterName "FSFilter" \
 --filterExpression "HaplotypeScore > 13.0" \
 --filterName "HaplotypeScoreFilter" \
 --filterExpression "MQRankSum < -12.5" \
 --filterName "MQRankSumFilter" \
 --filterExpression "ReadPosRankSum < -8.0" \
 --filterName "ReadPosRankSumFilter" \
 --filterExpression "QUAL < 30.0 || DP < 6 || DP > 5000 || HRun > 5" \
 --filterName "StandardFilters" \
 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
 --filterName "HARD_TO_VALIDATE" \
 -l OFF

 
mline=`grep -n "#CHROM" ${output_dir}/${subjectID}.snps.all.vcf | cut -d':' -f 1`
head -n $mline ${output_dir}/${subjectID}.snps.all.vcf > ${output_dir}/head.vcf
cat ${output_dir}/${subjectID}.snps.all.vcf |  \
grep PASS | cat ${output_dir}/head.vcf - >  \
${output_dir}/${subjectID}.snps.all.PASS.vcf

rm -f ${output_dir}/head.vcf
rm -f ${output_dir}/${subjectID}.snps.vcf
rm -f ${output_dir}/${subjectID}.snps.raw.all.vcf
rm -f ${output_dir}/*.idx
#rm -f $subjectDir/*.idx
rm -f ${output_dir}/variants/*.idx
