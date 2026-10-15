# Lepus granatensis

This folder contains the scripts used to analyse whole-genome sequencing data from 10 individuals belonging to three populations of the Iberian hare (_Lepus granatensis_) sampled in Spain (Andalusia, Extremadura and Madrid) for the Mind the Gap project.

Dataset label used in central analysis: `Lepus_granatensis`


## Author

- João P. Marques, CIBIO-InBIO, Portugal


## Dataset

| | |
|---|---|
| Species | _Lepus granatensis_ |
| Populations | Andalusia (n = 3), Extremadura (n = 3), Madrid (n = 4), Spain |
| Tissue | Ear and eyelid tissue, wild-caught individuals |
| DNA extraction | EZ-10 96-well plate Animal Genomic DNA Isolation Kit (Bio Basic), manufacturer's instructions |
| Library preparation | KAPA HyperPrep Kit with four-fold reduced reagent volumes; DNA sheared with a Bioruptor Pico and ~350 bp fragments selected with KAPA HyperPure beads; dual-indexed with IDT for Illumina TruSeq DNA UD Indexes v2 |
| Sequencing | Illumina NovaSeq X Plus (Novogene), paired-end 150 bp; variable number of lanes per sample |
| Coverage | ~4–5× per individual |
| Raw data | ENA study [PRJEB105583](https://www.ebi.ac.uk/ena/browser/view/PRJEB105583) |

| Sample | Population | Depth, draft (×) | Depth, chrom (×) |
|---|---|---|---|
| `Ca20Li2` | Andalusia | 4.65 | 4.56 |
| `Co22Li2` | Andalusia | 4.78 | 4.63 |
| `JA18LI3` | Andalusia | 5.15 | 5.04 |
| `M21_2392` | Extremadura | 4.94 | 4.86 |
| `M21_2746` | Extremadura | 5.53 | 5.42 |
| `M21_2783` | Extremadura | 4.98 | 4.81 |
| `CL_107` | Madrid | 4.65 | 4.55 |
| `IREC_21_Li117` | Madrid | 5.02 | 4.85 |
| `M22_0177` | Madrid | 4.75 | 4.60 |
| `M22_0284` | Madrid | 4.74 | 4.65 |


## Reference assemblies

The same processed reads were mapped to two assemblies of _L. granatensis_, both provided with this study (Zenodo: [DOI]):

| Label | File | Description |
|---|---|---|
| `chrom` | `mLepGra1.ref.fa` | Chromosome-level assembly, after scaffolding and curation at the Wellcome Sanger Institute |
| `draft` | `mLepGra1.draft.fa` | Draft assembly generated directly with hifiasm, before curation |


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
| 0 | [`00_repeatmask.bash`](scripts/00_repeatmask.bash) | §2, §4.1 | Soft-masks repeats with RepeatMasker (`-species "mammalia"`); builds BWA, samtools and GATK indexes |
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
