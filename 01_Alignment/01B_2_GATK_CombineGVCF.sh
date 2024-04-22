#!/bin/bash
#SBATCH --job-name="GATK Haplotypecaller"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-1%1
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_comb_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_comb_%A_%a.o

module load gatk

export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS"
export U_VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/GVCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"


###############################
#1. Combine GVCFs
###############################
#For GATK.list, it needs */path/sample_ID.list. Each sample needs own line
gatk CombineGVCFs \
	-R ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna \
	--variant ${U_VCF}/GATK.list \
	-O ${VCF}/GATK_120dronesamples.gvcf.vcf.gz




