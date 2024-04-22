#!/bin/bash
#SBATCH --job-name="Trim and BWA"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-120%120
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/00_RDS/tmp/BCFtools_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/00_RDS/tmp/BCFtools_%A_%a.o

module load trimmomatic
module load bwa
module load samtools
module load picard

export RDS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/00_RDS"
export tRDS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/01_tRDS"
export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export VCFS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03_VCFS"

#Make sure to index reference with "bwa index GCF_003254395.2_Amel_HAv3.1_genomic.fna"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"

mkdir ${BAMS}/dedup_metrics

#extract the sample file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}

###############################
#1. Trimming adapters with Trimmomatic
###############################

java -jar /software/7/apps/trimmomatic/0.38/trimmomatic-0.38.jar PE -threads 9 -phred33 ${RDS}/${ID}_R1_001.fastq.gz ${RDS}/${ID}_R2_001.fastq.gz \
${tRDS}/${ID}_1_TP.fastq.gz ${tRDS}/${ID}_1_TU.fastq.gz ${tRDS}/${ID}_2_TP.fastq.gz ${tRDS}/${ID}_2_TU.fastq.gz \
ILLUMINACLIP:/software/7/apps/trimmomatic/0.38/adapters/TruSeq3-PE.fa:2:30:10:2:keepBothReads \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

###############################
#2. Linear Alignment with BWA
###############################

bwa mem -t 10 ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna ${tRDS}/${ID}_1_TP.fastq.gz ${tRDS}/${ID}_2_TP.fastq.gz | samtools view -Shu - | samtools sort - | samtools rmdup -s - - | tee ${BAMS}/${ID}_BWA_sorted.bam


###############################
#3. Mark Duplicates
###############################

gatk MarkDuplicates \
	-I ${BAMS}/${ID}_BWA_sorted.bam \
	-O ${BAMS}/${ID}_BWA_sorted.dup.bam \
	-M ${BAMS}/dedup_metrics/${ID}.dup.metric \
	-AS true --CREATE_INDEX true --VALIDATION_STRINGENCY SILENT


###############################
#4. Add Read Groups
###############################

java -jar /software/7/apps/picard/2.27.1/picard.jar AddOrReplaceReadGroups \
      I=${BAMS}/${ID}_BWA_sorted.dup.bam \
      O=${BAMS}/${ID}_BWA_sorted.RG.dup.bam \
      RGID=${ID} \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=${ID}

###############################
#3. Index
###############################
samtools index ${BAMS}/${ID}_BWA_sorted.RG.dup.bam

