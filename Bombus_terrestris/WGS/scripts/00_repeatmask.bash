#!/usr/bin/env bash
# Protocol §2: soft-mask repeats in both assemblies, then index them (§4.1).
set -euo pipefail
source "$(dirname "$0")/config.sh"

for asm in $ASSEMBLIES; do
  fa=${ASM_FASTA[$asm]}
  RepeatMasker -pa "$THREADS" -species "$RM_SPECIES" -xsmall -gff \
    -dir assemblies/ "$fa"
  ln -sf "$(basename "$fa").masked" "assemblies/${asm}.soft.fa"

  bwa index "assemblies/${asm}.soft.fa"
  samtools faidx "assemblies/${asm}.soft.fa"
  gatk CreateSequenceDictionary -R "assemblies/${asm}.soft.fa"
done
