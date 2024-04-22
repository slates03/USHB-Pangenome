#!/bin/bash
#SBATCH --job-name="GATK Haplotypecaller"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-120%120
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_haplo_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_haplo_%A_%a.o


module load gatk
module load samtools
module load picard


export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the sample file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}


###############################
#1. Haplotypecaller
###############################

gatk HaplotypeCaller \
        -R ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna \
        -I ${BAMS}/${ID}_BWA_sorted.RG.dup.bam \
        -O ${VCF}/${ID}.gvcf.vcf.gz \
		-ploidy 1 -ERC GVCF -mbq 20 \
		-A Coverage -A FisherStrand -A StrandOddsRatio \
		-A MappingQualityRankSumTest -A QualByDepth \
		-A RMSMappingQuality -A ReadPosRankSumTest





