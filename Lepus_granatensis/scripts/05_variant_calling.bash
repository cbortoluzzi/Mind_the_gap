#!/usr/bin/env bash
# Protocol §5.1–5.3: per-sample GVCFs, combination and joint genotyping.
set -euo pipefail
source "$(dirname "$0")/config.sh"

mkdir -p gvcf vcf
for asm in $ASSEMBLIES; do
  ref=assemblies/${asm}.soft.fa
  : > "gvcf/list_${asm}.list"
  while IFS=$'\t' read -r sample species; do
    gatk HaplotypeCaller -R "$ref" \
      -I "bam/${sample}.${asm}.dedup.bam" \
      -ERC GVCF -O "gvcf/${sample}.${asm}.g.vcf.gz"
    echo "gvcf/${sample}.${asm}.g.vcf.gz" >> "gvcf/list_${asm}.list"
  done < "$SAMPLES"

  gatk CombineGVCFs -R "$ref" -V "gvcf/list_${asm}.list" -O "vcf/cohort.${asm}.g.vcf.gz"
  gatk GenotypeGVCFs -R "$ref" -V "vcf/cohort.${asm}.g.vcf.gz" -O "vcf/cohort.${asm}.raw.vcf.gz"
done
