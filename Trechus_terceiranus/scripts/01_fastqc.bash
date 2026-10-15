#!/usr/bin/env bash
# Protocol §3.1–3.2: FastQC on raw reads, aggregated with MultiQC.
set -euo pipefail
source "$(dirname "$0")/config.sh"

mkdir -p qc/fastqc
fastqc -t 8 "$READS_DIR"/*.fq.gz -o qc/fastqc
multiqc qc/fastqc -o qc
