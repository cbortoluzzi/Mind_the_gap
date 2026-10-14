# Bombus terrestris – WGS

This folder contains the scripts used to analyse whole-genome sequencing data from 10 individuals belonging to three populations of the buff-tailed bumblebee (_Bombus terrestris_) sampled in Portugal for the Mind the Gap project: continental Portugal (Porto/Póvoa de Varzim) and two Atlantic archipelagos (Azores and Madeira).

Dataset label used in central analysis: `Bombus_terrestris_Joao`


## Authors

- João P. Marques, CIBIO-InBIO, Portugal
- João Pimenta, CIBIO-InBIO, Portugal


## Dataset

| | |
|---|---|
| Species | _Bombus terrestris_ |
| Populations | Porto/Póvoa de Varzim, continental Portugal (n = 4), Azores (n = 3), Madeira (n = 3) |
| Tissue | Whole-body specimens from wild populations, preserved in 95 % ethanol |
| DNA extraction | EZ-10 Spin Column Genomic DNA Minipreps Kit (Bio Basic) with RNase A treatment; before extraction, one leg per specimen was washed overnight in 750 µL 1X PBS at 4–8 °C |
| Library preparation | Illumina DNA PCR-Free Library Prep, Tagmentation, with a 2× scale-down of volumes; low-input (< 300 ng) or standard (> 300 ng) workflow depending on gDNA concentration |
| Sequencing | Illumina NovaSeq X Plus (Novogene), paired-end 150 bp; one or two lanes per sample |
| Coverage | ~14× per individual |
| Raw data | ENA study [PRJEB106061](https://www.ebi.ac.uk/ena/browser/view/PRJEB106061) |

| Sample | Population | Depth, draft (×) | Depth, chrom (×) |
|---|---|---|---|
| `POL_B004` | Porto | 30.74 | 19.48 |
| `POL_B008` | Porto | 32.15 | 20.38 |
| `POL_B027` | Porto | 21.73 | 13.80 |
| `POL_B028` | Porto | 21.89 | 13.91 |
| `POL_B275` | Azores | 16.65 | 10.55 |
| `POL_B346` | Azores | 13.73 | 8.72 |
| `POL_B430` | Azores | 22.09 | 14.03 |
| `POL_B386` | Madeira | 19.34 | 16.53 |
| `POL_B392` | Madeira | 26.95 | 17.10 |
| `POL_B398` | Madeira | 22.05 | 13.96 |


## Reference assemblies

The same processed reads were mapped to two public assemblies of _B. terrestris_ (NCBI RefSeq):

| Label | Accession | Description |
|---|---|---|
| `chrom` | [GCF_910591885.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_910591885.1/) | Chromosome-level assembly |
| `draft` | [GCF_000214255.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000214255.1/) | Scaffold-level assembly |


## Environment

All analyses were run in the shared `chromcomp` conda environment of the Mind the Gap project (bwa 0.7.19, samtools 1.21, gatk4 4.6.2.0, plink2 2.00a3, vcftools 0.1.17, bcftools 1.21, RepeatMasker 4.1.9, plus FastQC, MultiQC and fastp).

```bash
conda activate chromcomp
```

Paths, thread counts and the RepeatMasker library are set in [`scripts/config.sh`](scripts/config.sh); [`scripts/samples.tsv`](scripts/samples.tsv) lists each sample and its population, used as groups for FST. Every script runs the same commands on both assemblies; only the reference changes.


## Workflow

Scripts are run in order from the project root.

| Step | Script | Protocol section | What it does |
|---|---|---|---|
| 0 | [`00_repeatmask.bash`](scripts/00_repeatmask.bash) | §2, §4.1 | Soft-masks repeats with RepeatMasker (`-species "insecta"`); builds BWA, samtools and GATK indexes |
| 1 | [`01_fastqc.bash`](scripts/01_fastqc.bash) | §3.1–3.2 | FastQC on raw reads, aggregated with MultiQC |
| 2 | [`02_fastp.bash`](scripts/02_fastp.bash) | §3.3 | Adapter, quality and poly-G trimming with fastp, per FASTQ pair |
| 3 | [`03_map.bash`](scripts/03_map.bash) | §4.2 | BWA-MEM mapping, separately for each lane, with read groups |
| 4 | [`04_dedup.bash`](scripts/04_dedup.bash) | §4.3 | Merging of all lanes of each individual during duplicate marking (GATK MarkDuplicates); indexing; flagstat |
| 5 | [`05_variant_calling.bash`](scripts/05_variant_calling.bash) | §5.1–5.3 | HaplotypeCaller (GVCF mode), CombineGVCFs, GenotypeGVCFs |
| 6 | [`06_filter.bash`](scripts/06_filter.bash) | §5.4 | Hard filtering (QD < 2, FS > 60, MQ < 40); PASS biallelic SNPs, call rate ≥ 80 %, MAF ≥ 5 % |
| 7 | [`07_popgen.bash`](scripts/07_popgen.bash) | §6 | LD pruning and PCA (PLINK 2); nucleotide diversity, heterozygosity/inbreeding, pairwise FST between populations and depth (VCFtools) |

```bash
for s in scripts/0*.bash; do bash "$s" &> "logs/$(basename "$s" .bash).oe"; done
```


## Dataset-specific deviations from the shared workflow

The only deviations from the shared workflow were in the population-genomic analyses with PLINK 2 (step 7):

- An externally generated allele-frequency file (computed beforehand with `plink2 --freq`) was supplied with `--read-freq`.
- `--bad-ld` was applied to bypass issues related to the small sample size.
- All scaffolds were retained with `--allow-extra-chr`.
- Variant identifiers were reformatted with `--set-all-var-ids @:#:$r,$a`.


## Outputs

Outputs delivered for central analysis, for each assembly: MultiQC report, duplicate metrics, mapping statistics, depth estimates, SNP/variant summaries, pruned SNP set, PCA, nucleotide diversity, heterozygosity estimates and inbreeding coefficients, and pairwise FST. There were no missing outputs or known limitations.
