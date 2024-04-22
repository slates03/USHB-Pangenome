#!/bin/bash
#SBATCH --job-name="VG Conct and Flt"    # job name
#SBATCH -p short                    # job queue
#SBATCH -N 1                        # job nodes
#SBATCH -n 20                       # threads per node
#SBATCH -t 48:00:00                  # job time (H:MM:SS)
#SBATCH --qos hbbgpl
#SBATCH --array 1-1%1
#SBATCH -e /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/tmp/VG_Flt_%A_%a.e
#SBATCH -o /90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/tmp/VG_Flt_%A_%a.o


module load bcftools

#Merge VCF
bcftools merge -m -l ${VCF_DIR}/vg_config.txt -o ${FIN_DIR}/Pan_var.raw.vcf

##Change Chromosome Names
bcftools annotate --rename-chr chrom.txt Pan_var.flt2.vcf.gz | bgzip > Pan_var.flt3.vcf.gz