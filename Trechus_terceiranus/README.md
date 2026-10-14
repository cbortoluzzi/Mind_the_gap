# Trechus terceiranus

This folder contains the scripts used to analyse whole-genome sequencing data from 10 individuals belonging to two closely related, co-occurring species of cave-dwelling ground beetles sampled on Terceira Island (Azores, Portugal) for the Mind the Gap project: _Trechus terceiranus_ (n = 5) and _Trechus terrabravensis_ (n = 5).

Dataset label used in central analysis: `Trechus_terceiranus`


## Authors

- João P. Marques, CIBIO-InBIO, Portugal
- Isabel R. Amorim, University of the Azores – cE3c, Portugal


## Dataset

| | |
|---|---|
| Species | _Trechus terceiranus_ (n = 5), _Trechus terrabravensis_ (n = 5) |
| Locality | Terceira Island, Azores (Portugal) |
| Tissue | Whole body, wild-caught individuals |
| DNA extraction | QIAamp DNA Micro Kit (standard protocol) |
| Library preparation | TruSeq DNA PCR-Free Library Prep Kit with IDT for Illumina–TruSeq DNA UD Indexes |
| Sequencing | Illumina NovaSeq, paired-end 150 bp; each library sequenced on two flowcells |
| Coverage | ~15–22× per individual |
| Raw data | ENA study [PRJEB128060](https://www.ebi.ac.uk/ena/browser/view/PRJEB128060) |


## Reference assemblies

The same processed reads were mapped to two assemblies of _T. terceiranus_, both provided with this study (Zenodo: [DOI]):

| Label | File | Description |
|---|---|---|
| `chrom` | `icTreTerc1.ref-non-curated.fa` | Flye-based assembly produced in collaboration with Tom Brown and Diego De Panis; still undergoing final manual curation at the Wellcome Sanger Institute at the time of analysis |
| `draft` | `icTreTerc1.draft.fa` | Highly preliminary draft assembly generated directly with hifiasm |


## Environment

All analyses were run in the shared `chromcomp` conda environment of the Mind the Gap project (bwa 0.7.19, samtools 1.21, gatk4 4.6.2.0, plink2 2.00a3, vcftools 0.1.17, bcftools 1.21, RepeatMasker 4.1.9, plus FastQC, MultiQC and fastp).

```bash
conda activate chromcomp
```

Paths, thread counts and the sample sheet are set in [`scripts/config.sh`](scripts/config.sh) and [`scripts/samples.tsv`](scripts/samples.tsv) (sample ID and species, used as groups for FST). Every script runs the same commands on both assemblies; only the reference changes.


## Workflow

Scripts are run in order from the project root.

| Step | Script | Protocol section | What it does |
|---|---|---|---|
| 0 | [`00_repeatmask.bash`](scripts/00_repeatmask.bash) | §2, §4.1 | Soft-masks repeats with RepeatMasker; builds BWA, samtools and GATK indexes |
| 1 | [`01_fastqc.bash`](scripts/01_fastqc.bash) | §3.1–3.2 | FastQC on raw reads, aggregated with MultiQC |
| 2 | [`02_fastp.bash`](scripts/02_fastp.bash) | §3.3 | Adapter, quality and poly-G trimming with fastp, per FASTQ pair |
| 3 | [`03_map.bash`](scripts/03_map.bash) | §4.2 | BWA-MEM mapping, separately for each flowcell/lane, with read groups |
| 4 | [`04_dedup.bash`](scripts/04_dedup.bash) | §4.3 | Merging of the lanes of each individual during duplicate marking (GATK MarkDuplicates); indexing; flagstat |
| 5 | [`05_variant_calling.bash`](scripts/05_variant_calling.bash) | §5.1–5.3 | HaplotypeCaller (GVCF mode), CombineGVCFs, GenotypeGVCFs |
| 6 | [`06_filter.bash`](scripts/06_filter.bash) | §5.4 | Hard filtering (QD < 2, FS > 60, MQ < 40); PASS biallelic SNPs, call rate ≥ 80 %, MAF ≥ 5 % |
| 7 | [`07_popgen.bash`](scripts/07_popgen.bash) | §6 | LD pruning and PCA (PLINK 2); nucleotide diversity, heterozygosity/inbreeding, pairwise FST between species and depth (VCFtools) |

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
