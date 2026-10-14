#!/usr/bin/env bash
# Protocol §4.2: BWA-MEM mapping to both assemblies.
# Each FASTQ pair (one per flowcell/lane) is mapped
# separately with its own read group; the lane-level BAMs of an individual
# are merged during duplicate marking (04_dedup.bash).
set -euo pipefail
source "$(dirname "$0")/config.sh"

mkdir -p bam qc
for asm in $ASSEMBLIES; do
  ref=assemblies/${asm}.soft.fa
  while IFS=$'\t' read -r sample species; do
    for r1 in trimmed/${sample}_*_1.trim.fq.gz; do
      unit=$(basename "$r1" _1.trim.fq.gz)
      r2=trimmed/${unit}_2.trim.fq.gz
      header=$(zcat "$r1" | head -n 1)
      flowcell=$(echo "$header" | cut -d ':' -f3)
      lane=$(echo "$header" | cut -d ':' -f4)
      rg="@RG\tID:${flowcell}.${lane}\tSM:${sample}\tLB:${sample}\tPL:ILLUMINA\tPU:${flowcell}.${lane}"

      bwa mem -M -t "$THREADS" -R "$rg" "$ref" "$r1" "$r2" \
        | samtools sort -@8 -o "bam/${unit}.${asm}.bam"
    done
  done < "$SAMPLES"
done
