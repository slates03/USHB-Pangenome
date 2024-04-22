module load miniconda
source activate /project/virus_rnaseq/2022_WGS_drone_stock/Panconda
module load bcftools
module load tabix 
module load vcftools


#-----------------------------------------------
#-Break up mutiallelic sites and annotate SV Type
#-----------------------------------------------
export VCF="/project/ushb_pangenome/garett.vcf/Raw_VCF"
export OUT="/project/ushb_pangenome/garett.vcf/SV/SV_Analysis"

sbatch --job-name="Pan SV " -p=short --wrap="
vcfbreakmulti ${VCF}/pan_120dronesamples.raw.vcf.gz | vcf-annotate --fill-type | \
	python /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src/SVLEN.py  - | bgzip -c > ${OUT}/SV_pan_120dronesamples.raw.vcf.gz
" --nodes=1 --ntasks=20 --qos=hbbgpl -t 48:00:00

#-----------------------------------------------
#-Filter
#-----------------------------------------------

sbatch --job-name="Filt SV" -p=short --wrap="
bcftools view ${OUT}/SV_pan_120dronesamples.raw.vcf.gz -f 'QUAL>30' -Ov  | \
	vcftools --vcf - --min-meanDP 7 --max-meanDP 66 --non-ref-ac 5 --recode --recode-INFO-all --stdout | \
	bgzip -c > ${OUT}/ANNO_MU_pan_120dronesamples.flt2.vcf.gz && \
	tabix -p vcf ${OUT}/ANNO_MU_pan_120dronesamples.flt2.vcf.gz
" --nodes=1 --ntasks=2 --qos=hbbgpl -t 48:00:00


#-----------------------------------------------
#-Filter INS/DEL/COMPLEX and recombine multiallelic Variants
#-----------------------------------------------

#--Deletions
java -jar /software/7/apps/snpeff/5.0e/SnpSift.jar filter "TYPE == 'del'" ANNO_MU_pan_120dronesamples.flt2.vcf.gz | \
	vcfcreatemulti > DEL_ANNO_MU_pan_120dronesamples.flt2.vcf.gz

#--Insertions
java -jar /software/7/apps/snpeff/5.0e/SnpSift.jar filter "TYPE == 'ins'" ANNO_MU_pan_120dronesamples.flt2.vcf.gz | \
	vcfcreatemulti > INS_ANNO_MU_pan_120dronesamples.flt2.vcf.gz

#--Complex
java -jar /software/7/apps/snpeff/5.0e/SnpSift.jar filter "TYPE == 'complex'" ANNO_MU_pan_120dronesamples.flt2.vcf.gz | \
	vcfcreatemulti > CPX_ANNO_MU_pan_120dronesamples.flt2.vcf.gz

#-----------------------------------------------
#-Annotate with VEP
#-----------------------------------------------
# SV analysis VEP
module load singularityCE/3.11.4

sbatch --job-name="CPX SV " -p=short --wrap="
singularity exec vep.sif vep -i CPX_ANNO_MU_pan_120dronesamples.flt2.vcf.gz -o CPX_VEP_ANNO_MU_pan_120dronesamples.flt2.vcf.gz \
   --regulatory --fork 4 --species apis_mellifera --variant_class --nearest symbol --overlaps --distance 200 --allele_number --total_length --numbers --vcf_info_field --mirna --database --genomes
" --nodes=1 --ntasks=2 --qos=hbbgpl -t 48:00:00

sbatch --job-name="DEL SV " -p=short --wrap="
singularity exec vep.sif vep -i DEL_ANNO_MU_pan_120dronesamples.flt2.vcf.gz -o DEL_VEP_ANNO_MU_pan_120dronesamples.flt2.vcf.gz \
   --regulatory --fork 4 --species apis_mellifera --variant_class --nearest symbol --overlaps --distance 200 --allele_number --total_length --numbers --vcf_info_field --mirna --database --genomes
" --nodes=1 --ntasks=2 --qos=hbbgpl -t 48:00:00


sbatch --job-name="INS SV " -p=short --wrap="
singularity exec vep.sif vep -i INS_ANNO_MU_pan_120dronesamples.flt2.vcf.gz -o INS_VEP_ANNO_MU_pan_120dronesamples.flt2.vcf.gz \
   --regulatory --fork 4 --species apis_mellifera --variant_class --nearest symbol --overlaps --distance 200 --allele_number --total_length --numbers --vcf_info_field --mirna --database --genomes
" --nodes=1 --ntasks=2 --qos=hbbgpl -t 48:00:00



