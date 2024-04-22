**00_SV_softfiltering.sh**

VCF files were soft filtered.

**01_SV_Annotation.sh**

SVs called from vg were first broken into single-allele variants using vcfbreakmulti from vcflib (v1.0.1) annotated using vcf-annotate --fill-type from the vcftools library; the variants were then split by annotated type, multiallelic SV recombined with vcfcreatemulti. 

SVs were then filtered based on SV Type (DEL, INS, and CPX), and the SV effect was annotated with VEP. 


**02_SV_Deconstruct_Graph.sh**
By default, all graphs are output in GFA (version 1.1) as well as the vg-native indexes: xg, snarls and GBWT formats . Because VCF remains more widely supported than these formats, we implemented a VCF exporter in vg (vg deconstruct) that is run as part of the Minigraph-Cactus pipeline. It outputs a site for each snarl in the graph. It uses the haplotype index (GBWT) to enumerate all haplotypes that traverse the site, which allows it to compute phased genotypes. For each allele, the corresponding path through the graph is stored in the AT (Allele Traversal) tag. Snarls can be nested, and this information is specified in the LV (Level) and PS (Parent Snarl) tags, which needs to be taken into account when interpreting the VCF. Any phasing information in the input assemblies is preserved in the VCF.

SVs called from vg were first broken into single-allele variants using vcfbreakmulti from vcflib (v1.0.1) annotated using vcf-annotate --fill-type from the vcftools library; the variants were then split by annotated type, multiallelic SV recombined with vcfcreatemulti. 

SVs were then filtered based on SV Type (DEL, INS, and CPX), and the SV effect was annotated with VEP. 

**03_SV_DELLY.sh**
Variants called by Delly2 for each individual with no soft-filter and high quality (QUAL > 30) were retained. Individuals’ SVs of the same type were combined using SURVIVOR (v1.0.7), allowing 100 bp of distance between break points and not accounting for the strand. This filtering excluded all the insertions, since Delly is incapable of calling insertions with precise break points, limiting the types of SV analyzed to deletions.

