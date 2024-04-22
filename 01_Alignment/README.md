# Trimming and Linear Alignment

**00_Trim_BWA_LinearAlignment.sh**

Raw pair-end reads were filtered with Trimmomatic (v0.38, MINLEN: 36) and mapped to the reference genome Amel_HAv3.1 using bwa-mem (v0.7.17) 

Duplicates were marked and removed using gatk MarkDuplicates (v4.4.0.0 and read groups were added with picard (version 3.0.0; http:// broadinstitute.github.io/picard/). 

# BcfTools

**01A_1_BCFtools_VariantsCalling.sh**

Bam files were supplied to mpileup (–Q 20 option; bcftools v1.16)

**01A_2_BCFTools_Concat.sh**

Resulting VCFs were merged

# GATK

**01B_1_GATK_HaplotypeCaller.sh**

Each drone was genotyped independently with gatk haplotypecaller using the haploid model. 

**01B_2_GATK_CombineGVCF.sh**

Individual gVCF files were combined with gatk combinegvcfs. 

**01B_3_GATK_Genotype.sh**

Then, they were jointly genotyped with gatk genotypegvcfs, resulting in a single VCF file for the 120 samples

**01B_4_GATK_Concat.sh**

The Indidividual chromosomes were merged.

# VG
**01A_1_BCFtools_VariantsCalling.sh**

Raw pair-end reads from each stock were filtered with Trimmomatic (v0.38, MINLEN: 36). 

**01C_1_VG_VariantCalling.sh**

The fastq files were aligned to the graph generated above using giraffe (vgtools v1.51.0), following the pipeline based on index construction from a GFA file with embedded path information. Variants and structural variants were called using vg call, which employs a probabilistic model to identify variants and can detect structural variants. Only reads with Mapping Quality (MQ) = 60 were retained

**01C_2_VG_Merge.sh**

Resulting VCFs were merged


