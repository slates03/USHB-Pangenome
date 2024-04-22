#!/bin/bash
#SBATCH --job-name="GATK Genotyping"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-16%16
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_Geno_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_Geno_%A_%a.o


module load gatk


export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the chromosome file from the index files (note these need to be created)
export LG=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/LG.txt)
echo ${LG}


###############################
#1. Genotype
###############################
gatk GenotypeGVCFs \
	-R ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna \
	-V ${VCF}/GATK_120dronesamples.gvcf.vcf.gz \
	-L ${LG} \
	-ploidy 1 \
	-A Coverage -A FisherStrand -A StrandOddsRatio \
	-A MappingQualityRankSumTest -A QualByDepth \
	-A RMSMappingQuality -A ReadPosRankSumTest \
	-O ${VCF}/${LG}.GATK_120dronesamples.gvcf.vcf.gz



