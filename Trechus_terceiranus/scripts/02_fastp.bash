#!/usr/bin/env bash
# Protocol §3.3: adapter/quality trimming with fastp, one run per FASTQ pair
# (each sample was sequenced on two flowcells/lanes).
set -euo pipefail
source "$(dirname "$0")/config.sh"

mkdir -p trimmed qc/fastp
for r1 in "$READS_DIR"/*_1.fq.gz; do
  unit=$(basename "$r1" _1.fq.gz)
  fastp \
    -i "$r1" -I "$READS_DIR/${unit}_2.fq.gz" \
    -o "trimmed/${unit}_1.trim.fq.gz" -O "trimmed/${unit}_2.trim.fq.gz" \
    -q 20 -u 30 -l 50 -g \
    -h "qc/fastp/${unit}.fastp.html" -j "qc/fastp/${unit}.fastp.json" \
    -w 8
done
