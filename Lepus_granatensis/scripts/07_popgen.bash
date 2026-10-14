#!/usr/bin/env bash
# Protocol §6: LD pruning and PCA (PLINK 2); nucleotide diversity,
# heterozygosity/inbreeding and pairwise FST (VCFtools).
#
# Dataset-specific deviations (PLINK 2), needed because of the small sample size
# (n = 10; PLINK 2 refuses LD pruning and PCA with fewer than 50 samples unless
# allele frequencies are supplied):
#   --read-freq          allele frequencies generated beforehand with --freq
#   --bad-ld             bypass the small-sample LD check
#   --allow-extra-chr    keep all scaffolds
#   --set-all-var-ids    reformat variant IDs as @:#:$r,$a
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
source "$here/config.sh"

# One file per population (sample IDs, one per line), built from samples.tsv
mkdir -p stats/pops
pops=()
for pop in $(cut -f2 "$SAMPLES" | sort -u); do
  awk -v p="$pop" '$2==p {print $1}' "$SAMPLES" > "stats/pops/${pop}.txt"
  pops+=("$pop")
done

for asm in $ASSEMBLIES; do
  vcf=vcf/cohort.${asm}.final.recode.vcf.gz
  out=stats/${asm}
  mkdir -p "$out"
  prefix=$out/${DATASET}-${asm}.MtG

  # Convert to PLINK 2 format with unique variant IDs
  plink2 --vcf "$vcf" --allow-extra-chr \
    --set-all-var-ids '@:#:$r,$a' \
    --make-pgen --out "${prefix}_fixed_ids"

  # Allele frequencies, supplied to the steps below with --read-freq
  plink2 --pfile "${prefix}_fixed_ids" --allow-extra-chr \
    --freq --out "${prefix}_freq"

  # Step A: LD pruning (r2 < 0.2, 50 kb windows, step 10 variants)
  plink2 --pfile "${prefix}_fixed_ids" --allow-extra-chr \
    --read-freq "${prefix}_freq.afreq" --bad-ld \
    --indep-pairwise 50 10 0.2 \
    --out "$out/pruned_${asm}"

  # Step B: PCA on the pruned SNP set
  plink2 --pfile "${prefix}_fixed_ids" --allow-extra-chr \
    --read-freq "${prefix}_freq.afreq" \
    --extract "$out/pruned_${asm}.prune.in" \
    --pca 10 \
    --out "$out/pca_${asm}"

  # VCF with the same variant IDs, so that pruned_${asm}.prune.in matches in VCFtools
  bcftools annotate --set-id '%CHROM:%POS:%REF,%ALT' -Oz \
    -o "$out/cohort.${asm}.final.ids.vcf.gz" "$vcf"
  ids_vcf=$out/cohort.${asm}.final.ids.vcf.gz

  # Nucleotide diversity
  vcftools --gzvcf "$ids_vcf" --snps "$out/pruned_${asm}.prune.in" \
    --site-pi --out "$out/pi_${asm}"

  # Observed heterozygosity and inbreeding coefficient (F) per individual
  vcftools --gzvcf "$ids_vcf" --snps "$out/pruned_${asm}.prune.in" \
    --het --out "$out/het_${asm}"

  # Pairwise FST between all pairs of populations
  for ((i = 0; i < ${#pops[@]}; i++)); do
    for ((j = i + 1; j < ${#pops[@]}; j++)); do
      a=${pops[$i]}; b=${pops[$j]}
      vcftools --gzvcf "$ids_vcf" --snps "$out/pruned_${asm}.prune.in" \
        --weir-fst-pop "stats/pops/${a}.txt" \
        --weir-fst-pop "stats/pops/${b}.txt" \
        --out "$out/fst_${asm}_${a}_vs_${b}"
    done
  done

  # Per-individual mean depth at the filtered SNPs
  vcftools --gzvcf "$vcf" --depth --out "$out/depth_${asm}"
done
