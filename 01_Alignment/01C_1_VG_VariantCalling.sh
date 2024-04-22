#!/bin/bash
#SBATCH --job-name="VG Variant Calling"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-120%120
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/tmp/VG_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/tmp/VG_%A_%a.o


module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda
module load bcftools
module load picard
module load samtools



export tRDS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/01_tRDS"
export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS"
export VCFS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03C_PAN_VCFS"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/Pangenome/apis.8"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"
export sing="/project/virus_rnaseq/2022_WGS_drone_stock/containers"

#extract the sample file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}

###############################
#1. Alignment with VG Giraffe. (V 1.51)
###############################

vg giraffe --threads 4  --progress -Z ${REF}/apis.8.gbz -d ${REF}/apis.8.dist -m ${REF}/apis.8.min -f ${tRDS}/${ID}_1_TP.fastq.gz -f ${tRDS}/${ID}_2_TP.fastq.gz > ${BAMS}/${ID}.gam

vg filter --threads 4 --min-mapq 60 ${BAMS}/${ID}.gam > ${BAMS}/${ID}.mq60.gam 

vg pack --threads 4 -x ${REF}/apis.8.gbz -g ${BAMS}/${ID}.mq60.gam  -o ${BAMS}/${ID}.mq60.pack


###############################
#2. Variant Calling with VG call (V 1.46)
###############################
conda deactivate
source activate trinityenv
vg call ${REF}/apis.8.gbz -k ${BAMS}/${ID}.mq60.pack -s ${ID} -d 1 -a | bgzip > ${VCFS}/${ID}.vcf.gz

tabix -p vcf ${VCFS}/${ID}.vcf.gz




