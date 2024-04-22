#!/bin/bash
#SBATCH --job-name="BCFtools Concat"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-1%1
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS/tmp/BCFtools_flt_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS/tmp/BCFtools_flt_%A_%a.o

module load bcftools
module load tabix
module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda


export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03A_Bcftools_VCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"

###############################
#1. Concat chromosomes
###############################

bcftools concat -f ${VCF}/concat.txt -Oz > ${VCF}/bcftools_120dronesamples.raw.vcf.gz
tabix -p vcf ${VCF}/bcftools_120dronesamples.raw.vcf.gz



