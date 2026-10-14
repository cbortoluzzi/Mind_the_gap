#!/usr/bin/env bash
# Shared settings, sourced by every script in this folder. Edit paths here only.

DATASET=Lepus_granatensis

# Assemblies (provided with this study; see README)
declare -A ASM_FASTA=(
  [draft]=assemblies/mLepGra1.draft.fa
  [chrom]=assemblies/mLepGra1.ref.fa
)
ASSEMBLIES="draft chrom"

# Two-column sample sheet: sample_id<TAB>population (used for FST)
SAMPLES="$(dirname "${BASH_SOURCE[0]}")/samples.tsv"

# Raw reads (Novogene delivery: <sample>_<library>_<flowcell>_L<lane>_{1,2}.fq.gz)
READS_DIR=reads

# RepeatMasker library hint
RM_SPECIES="mammalia"

# Threads
THREADS=16
