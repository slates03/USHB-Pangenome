#!/bin/bash
#SBATCH --job-name="GATK Haplotypecaller"    # job name
#SBATCH -p medium                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 7-00:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-120%120
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_haplo_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03B_GATK_VCFS/tmp/GATK_haplo_%A_%a.o

module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda
module load gatk
module load samtools
module load picard
module load bcftools


export VG_BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS"
export VG_BAMS_OUT="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/vg_stats"
export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export BAMS_OUT="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS/stats"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the sample file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}


###############################
#1. Statistics
###############################
#GAM Stats
vg stats -a ${VG_BAMS}/${ID}.gam > ${VG_BAMS_OUT}/stats_${ID}.txt

#BAM Stats
bamtools stats -insert -in ${BAMS}/${ID}_BWA_sorted.RG.dup.bam > ${BAMS_OUT}/stats_${ID}.json


###############################
#2. Perfect Alignment
###############################
#Perfect Alignment BAM Files
samtools view ${BAMS}/${ID}_BWA_sorted.RG.dup.bam  | awk '$0 ~"NM:i:0"' | wc -l > ${BAMS_OUT}/${ID}_perfect_align.txt

#Perfect Alignment GAM Files
vg view -a ${VG_BAMS}/${ID}.gam | jq -c 'select(.identity==1.0)' | wc -l > ${VG_BAMS_OUT}/${ID}_vg_perfect_align.txt


###############################
#3. Mapping Quality
###############################
#Number of Reads with Mapping Quality >60 in BAM Files
samtools view ${BAMS}/${ID}_BWA_sorted.RG.dup.bam --no-header -q 60 | wc -l > ${BAMS_OUT}/${ID}_mq60.json

#Number of Reads with Mapping Quality >60 in GAM Files
vg view -a ${VG_BAMS}/${ID}.mq60.gam  | wc -l > ${VG_BAMS_OUT}/${ID}_vg_mq60.txt





