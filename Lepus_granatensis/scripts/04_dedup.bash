#!/usr/bin/env bash
# Protocol §4.3: duplicate marking and indexing.
# All lane-level BAMs of each individual are merged here (one -I per lane),
# so duplicates are detected across all sequencing runs of the same library.
set -euo pipefail
source "$(dirname "$0")/config.sh"

for asm in $ASSEMBLIES; do
  while IFS=$'\t' read -r sample species; do
    inputs=()
    for b in bam/${sample}_*.${asm}.bam; do inputs+=(-I "$b"); done

    gatk MarkDuplicates "${inputs[@]}" \
      -O "bam/${sample}.${asm}.dedup.bam" \
      -M "qc/${sample}.${asm}.dup.txt"
    samtools index "bam/${sample}.${asm}.dedup.bam"
    samtools flagstat "bam/${sample}.${asm}.dedup.bam" > "qc/${sample}.${asm}.flagstat.txt"
  done < "$SAMPLES"
done
