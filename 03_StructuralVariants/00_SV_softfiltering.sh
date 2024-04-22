#!/bin/bash
#SBATCH --job-name="Soft Filtering"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-120%120
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/06A_SVANALYSIS/tmp/filtering_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/06A_SVANALYSIS/tmp/filtering_%A_%a.o

module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda
module load bcftools
module load tabix 

export VCF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03C_PAN_VCFS"
export OUT="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/03C_PAN_VCFS/Solf_Filter"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"

#extract the chromosome file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}

bcftools view -O z -f '.,PASS' ${VCF}/${ID}.vcf.gz -Oz > ${OUT}/${ID}.filt.vcf.gz
tabix -p vcf ${OUT}/${ID}.filt.vcf.gz 
