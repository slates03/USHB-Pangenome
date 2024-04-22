#!/bin/bash
#SBATCH --job-name="BCFtools mpileup"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-16%16
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS/tmp/BCFtools_mpileup_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS/tmp/BCFtools_mpileup_%A_%a.o

module load bcftools


export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the chromosome file from the index files (note these need to be created)
export LG=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/LG.txt)
echo ${LG}

###############################
# Variant Calling with bcftools
###############################

#List of chromosomes
#Note: bam.txt file needs to be created. It needs to have the location of bams: /path/sample.bam

bcftools mpileup -Ou -f ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna -r ${LG} -b ${BAMS}/bam.txt | \
bcftools call -Ou -mv --ploidy 1 > ${VCF}/${LG}_bcftools_var.raw.vcf







