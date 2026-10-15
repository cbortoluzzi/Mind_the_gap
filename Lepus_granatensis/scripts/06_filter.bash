#!/usr/bin/env bash
# Protocol §5.4: hard filtering, then PASS biallelic SNPs with
# call rate >= 80% and MAF >= 5%.
set -euo pipefail
source "$(dirname "$0")/config.sh"

cd vcf
for asm in $ASSEMBLIES; do
  ref=../assemblies/${asm}.soft.fa
  gatk VariantFiltration -R "$ref" \
    -V "cohort.${asm}.raw.vcf.gz" \
    --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
    --filter-name "basic_snp_filter" \
    -O "cohort.${asm}.flt.vcf.gz"

  bcftools view -f PASS -m2 -M2 -v snps "cohort.${asm}.flt.vcf.gz" \
    | vcftools --vcf - --max-missing 0.8 --maf 0.05 \
        --min-alleles 2 --max-alleles 2 \
        --recode --recode-INFO-all --out "cohort.${asm}.final"
  bgzip -f "cohort.${asm}.final.recode.vcf"
  tabix -f -p vcf "cohort.${asm}.final.recode.vcf.gz"

  # SNP/variant summary
  bcftools stats "cohort.${asm}.final.recode.vcf.gz" > "cohort.${asm}.final.stats.txt"
done
