#!/usr/bin/env bash
# Shared settings, sourced by every script in this folder. Edit paths here only.

DATASET=Bombus_terrestris_Joao

# Assemblies (NCBI RefSeq; see README)
declare -A ASM_FASTA=(
  [draft]=assemblies/GCF_000214255.1_Bter_1.0_genomic.fna
  [chrom]=assemblies/GCF_910591885.1_iyBomTerr1.2_genomic.fna
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
