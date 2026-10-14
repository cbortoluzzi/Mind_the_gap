#!/usr/bin/env bash
# Shared settings, sourced by every script in this folder. Edit paths here only.

DATASET=Trechus_terceiranus

# Assemblies (provided with this study; see README)
declare -A ASM_FASTA=(
  [draft]=assemblies/icTreTerc1.draft.fa
  [chrom]=assemblies/icTreTerc1.ref-non-curated.fa
)
ASSEMBLIES="draft chrom"

# Two-column sample sheet: sample_id<TAB>population (used for FST)
SAMPLES="$(dirname "${BASH_SOURCE[0]}")/samples.tsv"

# Raw reads (Novogene delivery: <sample>_<library>_<flowcell>_L<lane>_{1,2}.fq.gz)
READS_DIR=reads

# RepeatMasker library hint
RM_SPECIES="insecta"

# Threads
THREADS=16
