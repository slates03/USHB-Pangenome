#!/bin/bash
#SBATCH --job-name="REHH Prep 00"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-6%6
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/05A_PopGen/VCF/tmp/VG_Flt_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/05A_PopGen/VCF/tmp/VG_Flt_%A_%a.o

cd /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src

module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda
module load vcftools
module load shapeit


export Final_DIR="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/05A_PopGen/REHH"
export SRC="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the sample file from the index files (note these need to be created)
export U_line=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${SRC}/lines.txt)
echo ${U_line}

mkdir ${Final_DIR}/${U_line}/phased

chr_set="lg1 lg2 lg3 lg4 lg5 lg6 lg7 lg8 lg9 lg10 lg11 lg12 lg13 lg14 lg15 lg16" 

for lg in ${chr_set}
do

shapeit --input-vcf ${Final_DIR}/${U_line}/${U_line}_${lg}.recode.vcf \
        -M  ${Final_DIR}/genetic_maps/${lg}.txt \
        --force \
        -O ${Final_DIR}/${U_line}/phased/phased_${U_line}_${lg} \
        --thread 6

shapeit -convert \
    --input-haps ${Final_DIR}/${U_line}/phased/phased_${U_line}_${lg} \
    --output-vcf ${Final_DIR}/${U_line}/phased/phased_${U_line}_${lg}.vcf


done


