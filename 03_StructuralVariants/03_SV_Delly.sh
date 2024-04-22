###############################
#1. Run Delly
###############################

module load delly

export BAMS="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02_BAMS"
export OUT="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/04A_SV_Delly/Same_FN_Insertions"
export REF="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/References/GCF_003254395.2"
export src="/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src"


#extract the chromosome file from the index files (note these need to be created)
export ID=$(sed -n -e "$SLURM_ARRAY_TASK_ID P" ${src}/sample.txt)
echo ${ID}



delly call -g ${REF}/GCF_003254395.2_Amel_HAv3.1_genomic.fna ${BAMS}/${ID}_BWA_sorted.RG.dup.bam -t ALL > ${OUT}/${ID}_INS_delly.vcf

bgzip -c  ${RDS}/${ID}_delly.vcf > ${RDS}/${ID}_delly.vcf.gz
tabix -p vcf ${RDS}/${ID}_delly.vcf.gz

###############################
#2. Merge Delly
###############################

SURVIVOR merge delly_merge.txt 100 1 1 0 0 0 INSERTIONS


