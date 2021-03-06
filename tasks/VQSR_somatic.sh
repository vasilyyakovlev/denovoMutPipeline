#! /bin/bash

# Variant filtering according to GATK best practices for getting best call set for > 30 exome bams
# If < 30 are available, use hard filters in varFilter.sh or augment bams with 1000 genome bam files

mkdir ${output_dir}/varfilter


#java -Xmx${heap}m -jar $gatk \
#   -T VariantAnnotator \
#   -R $REF\
#   -I ${output_dir}/${subjectID}_${tumor}.bam \
#   -L ${output_dir}/${sname}.raw.snvs.vcf \
#   -o ${output_dir}/${sname}.ann.snvs.vcf \
#   -A Coverage \
#   -A QualByDepth \
#   --variant ${output_dir}/${sname}.raw.snvs.vcf \
#   --dbsnp $DBSNP

# Build error model for SNPs
java -Xmx${heap}m -jar $gatk \
   -T VariantRecalibrator \
   -R $REF\
   -input:VCF ${output_dir}/${sname}.ann.snvs.vcf \
   -recalFile ${output_dir}/${sname}.raw.snvs.recal \
   -tranchesFile ${output_dir}/${sname}.raw.snvs.tranches \
   -nt 1 \
   -percentBad 0.01 -minNumBad 1000 \
   -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmap \
   -resource:omni,known=false,training=true,truth=true,prior=12.0 $omni \
   -resource:1000G,known=false,training=true,truth=false,prior=10.0 $phase1 \
   -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DBNSP \
   -an QD -an MQRankSum -an ReadPosRankSum -an FS \
   -mode SNP
    #-an DP \ # NOTE: Shouldn't use DP with hybrid capture data sets

# Apply error model to SNPs
java -Xmx${heap}m -jar $gatk \
   -T ApplyRecalibration \
   -R $REF \
   -input:VCF ${output_dir}/${sname}.ann.snvs.vcf \
   -tranchesFile ${output_dir}/${sname}.raw.snvs.tranches \
   -recalFile ${output_dir}/${sname}.raw.snvs.recal \
   -o ${output_dir}/${sname}.snvs.recal.filtered.vcf \
   --ts_filter_level 99.9 \
   -mode SNP

# Build error model for INDELs
java -Xmx${heap}m -jar $gatk \
   -T VariantRecalibrator \
   -R $REF\
   -input:VCF ${output_dir}/${sname}.raw.indels.vcf \
   -recalFile ${output_dir}/${sname}.raw.indels.recal \
   -tranchesFile ${output_dir}/${sname}.raw.indels.tranches \
   -nt 1 \
   --maxGaussians 4 -percentBad 0.01 -minNumBad 1000 \
   -resource:mills,known=false,training=true,truth=true,prior=12.0 $mills \
   -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DBNSP \
   -an FS -an ReadPosRankSum -an MQRankSum \
   -mode INDEL
   #-an DP 

# Apply error model to INDELs
java -Xmx${heap}m -jar $gatk \
   -T ApplyRecalibration \
   -R $REF \
   -input:VCF ${output_dir}/${sname}.raw.indels.vcf \
   -tranchesFile ${output_dir}/${sname}.raw.indels.tranches \
   -recalFile ${output_dir}/${sname}.raw.indels.recal \
   -o ${output_dir}/${sname}.indels.recal.filtered.vcf \
   --ts_filter_level 99.9 \
   -mode INDEL

rm -f ${output_dir}/variants/*.idx

# Pull out "Passing"
mline2=`grep -n "#CHROM" ${output_dir}/${sname}.indels.recal.filtered.vcf | cut -d':' -f 1`
head -n $mline2 ${output_dir}/${sname}.indels.recal.filtered.vcf > ${output_dir}/headindels.vcf
cat ${output_dir}/${sname}.indels.recal.filtered.vcf | grep PASS | cat ${output_dir}/headindels.vcf - > ${output_dir}/${sname}.indels.PASS.vcf

rm -f ${output_dir}/headindels.vcf

mline=`grep -n "#CHROM" ${output_dir}/${sname}.snps.recal.filtered.vcf | cut -d':' -f 1`
head -n $mline ${output_dir}/${sname}.snvs.recal.filtered.vcf > ${output_dir}/head.vcf
cat ${output_dir}/${sname}.snvs.recal.filtered.vcf | grep PASS | cat ${output_dir}/head.vcf - > ${output_dir}/${sname}.snvs.PASS.vcf
  
rm -f ${output_dir}/head.vcf

java -Xmx${heap}m -jar $gatk \
   -T VariantEval \
   --dbsnp $DBSNP \
   -R $REF \
   -eval ${output_dir}/${sname}.snvs.PASS.vcf \
   -o ${output_dir}/${sname}.snvs.PASS.vcf.eval

java -Xmx${heap}m -jar $gatk \
   -T VariantEval \
   --dbsnp $DBSNP \
   -R $REF \
   -eval ${output_dir}/${sname}.indels.PASS.vcf \
   -o ${output_dir}/${sname}.indels.PASS.vcf.eval
 
rm -f ${output_dir}/*.idx
