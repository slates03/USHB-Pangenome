#!/bin/bash
#SBATCH --job-name="GATK Concat"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-1%1
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_concat_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_concat_%A_%a.o

module load picard

export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS"


###############################
#1. Combine Chromosomes
###############################

java -jar /software/7/apps/picard/2.27.1/picard.jar GatherVcfs \
      I=${VCF}/NC_037638.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037639.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037640.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037641.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037642.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037643.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037644.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037645.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037646.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037647.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037648.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037649.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037650.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037651.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037652.1.GATK_120dronesamples.gvcf.vcf.gz \
      I=${VCF}/NC_037653.1.GATK_120dronesamples.gvcf.vcf.gz \
      O=${VCF}/GATK_120dronesamples.raw.vcf

