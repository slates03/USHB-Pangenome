#-----
# Genes
#----
library(rtracklayer)
gr <- import("~/OneDrive/Manuscripts/Pangenome/Resources/GCF_003254395.2_Amel_HAv3.1_genomic.gff", format="gff")
gr<-gr[which(gr$type=="gene"),]
gr2<-gr[,c(6,18)]

gr2<-data.frame(gr2)
gr2<- separate(gr2, Dbxref, into = c("Column_1", "Column_2"), sep = ",")
gr2$Column_1 <- gsub("c(", "", gr2$Column_1)
gr2$Column_1 <- gsub('"', '', gr2$Column_1)
gr2$Column_1 <- gsub('c\\(', '', gr2$Column_1)
gr2$Column_1 <- gsub("GeneID:", "", gr2$Column_1)

gr2$seqnames<-as.character(gr2$seqnames)

#Change Chromsome Name
gr2$seqnames[gr2$seqnames == "NC_037638.1"] <- "1"
gr2$seqnames[gr2$seqnames == "NC_037639.1"] <- "2"
gr2$seqnames[gr2$seqnames == "NC_037640.1"] <- "3"
gr2$seqnames[gr2$seqnames == "NC_037641.1"] <- "4"
gr2$seqnames[gr2$seqnames == "NC_037642.1"] <- "5"
gr2$seqnames[gr2$seqnames == "NC_037643.1"] <- "6"
gr2$seqnames[gr2$seqnames == "NC_037644.1"] <- "7"
gr2$seqnames[gr2$seqnames == "NC_037645.1"] <- "8"
gr2$seqnames[gr2$seqnames == "NC_037646.1"] <- "9"
gr2$seqnames[gr2$seqnames == "NC_037647.1"] <- "10"
gr2$seqnames[gr2$seqnames == "NC_037648.1"] <- "11"
gr2$seqnames[gr2$seqnames == "NC_037649.1"] <- "12"
gr2$seqnames[gr2$seqnames == "NC_037650.1"] <- "13"
gr2$seqnames[gr2$seqnames == "NC_037651.1"] <- "14"
gr2$seqnames[gr2$seqnames == "NC_037652.1"] <- "15"
gr2$seqnames[gr2$seqnames == "NC_037653.1"] <- "16"


gr3 <- makeGRangesFromDataFrame(gr2, start.field = "start", end.field = "end", seqnames.field = "seqnames")
mcols(gr3)$GENE <- gr2$gene
mcols(gr3)$GB <- gr2$Column_1
gr3<- subset(gr3, !grepl("^NC", seqnames(gr3)))
gr3<- subset(gr3, !grepl("^NW", seqnames(gr3)))
saveRDS(gr3,"GFF.RDS")
#--------
# kPI/pPI
#--------
K_PI<-read.table("~/OneDrive/Manuscripts/Pangenome/Resources/Selection/BI_SNPS_pi_kona_sites.pi",header=T)
K_PI$ID2<-paste(K_PI$CHROM,K_PI$POS,sep="_")
colnames(K_PI)[3]<-"K_PI"

P_PI<-read.table("~/OneDrive/Manuscripts/Pangenome/Resources/Selection/BI_SNPS_pi_polline_sites.pi",header=T)
P_PI$ID2<-paste(P_PI$CHROM,P_PI$POS,sep="_")
colnames(P_PI)[3]<-"P_PI"

PI<-merge(K_PI,P_PI,by="ID2")
PI$PI<-PI$K_PI/PI$P_PI
PI[is.na(PI)] <- 0
PI<-PI[which(PI$PI!="Inf"),]

#--------
# rsb
#--------
rsb<-read.table("~/OneDrive/Manuscripts/Pangenome/Resources/Selection/BI_SNPS_rsb_pol_kona.txt",header=T)
rsb$rSB2<-exp(rsb$rSB)
rsb$ID2<-paste(rsb$CHR,rsb$POSITION,sep="_")

#--------
# FST
#--------
fst<-read.table("~/OneDrive/Manuscripts/Pangenome/Resources/Selection/BI_SNPS_polline_vs_kona_FST.weir.fst",header=T)
fst$ID2<-paste(fst$CHROM,fst$POS,sep="_")
fst<-na.omit(fst)
fst[fst < 0] <- 0


#--------
# SNP Weights
#--------
SNP_Weight<-read.table("~/OneDrive/Manuscripts/Pangenome/Resources/Selection/KvP_snp_weights2",header=T)
SNP_Weight$PC1_P2<-p.adjust(SNP_Weight$PC1_P,method="fdr")
SNP_Weight$CHROM[SNP_Weight$CHR == "1"] <- "lg1"
SNP_Weight$CHROM[SNP_Weight$CHR == "2"] <- "lg2"
SNP_Weight$CHROM[SNP_Weight$CHR == "3"] <- "lg3"
SNP_Weight$CHROM[SNP_Weight$CHR == "4"] <- "lg4"
SNP_Weight$CHROM[SNP_Weight$CHR == "5"] <- "lg5"
SNP_Weight$CHROM[SNP_Weight$CHR == "6"] <- "lg6"
SNP_Weight$CHROM[SNP_Weight$CHR == "7"] <- "lg7"
SNP_Weight$CHROM[SNP_Weight$CHR == "8"] <- "lg8"
SNP_Weight$CHROM[SNP_Weight$CHR == "9"] <- "lg9"
SNP_Weight$CHROM[SNP_Weight$CHR == "10"] <- "lg10"
SNP_Weight$CHROM[SNP_Weight$CHR == "11"] <- "lg11"
SNP_Weight$CHROM[SNP_Weight$CHR == "12"] <- "lg12"
SNP_Weight$CHROM[SNP_Weight$CHR == "13"] <- "lg13"
SNP_Weight$CHROM[SNP_Weight$CHR == "14"] <- "lg14"
SNP_Weight$CHROM[SNP_Weight$CHR == "15"] <- "lg15"
SNP_Weight$CHROM[SNP_Weight$CHR == "16"] <- "lg16"
SNP_Weight$ID2<-paste(SNP_Weight$CHROM,SNP_Weight$POS,sep="_")
SNP_Weight<-na.omit(SNP_Weight)

#--------
# All Merged
#--------
SNP<-merge(PI, rsb,by="ID2")
SNP<-merge(SNP, fst ,by="ID2")
SNP<-merge(SNP, SNP_Weight ,by="ID2")
SNP<-SNP[,c(1,2,3,8,13,16,26)]
colnames(SNP)<-c("ID2","CHROM","POS","PI","rSB2","FST","PC1")

#--------
# CSS Score
#--------

SNP$rsb_R<-rank(-SNP$rSB2)
SNP$fst_R<-rank(-SNP$FST)
SNP$PI_R<-rank(-SNP$PI)
SNP$SW_R<-rank(SNP$PC1)

SNP$rsb_R<-SNP$rsb_R/(nrow(SNP)+1)
SNP$fst_R<-SNP$fst_R/(nrow(SNP)+1)
SNP$PI_R<-SNP$PI_R/(nrow(SNP)+1)
SNP$SW_R<-SNP$SW_R/(nrow(SNP)+1)

SNP$rsb_Z<-qnorm(SNP$rsb_R)
SNP$fst_Z<-qnorm(SNP$fst_R)
SNP$PI_Z<-qnorm(SNP$PI_R)
SNP$SW_Z<-qnorm(SNP$SW_R)

SNP$Z<-rowMeans(SNP[,c(12,14,15)])
library(fdrtool)

fdr = fdrtool(SNP$Z)
SNP$P<-fdr$pval
SNP$CSS<--log10(SNP$P)



SNP$CHROM<-as.character(SNP$CHROM)
SNP$CHR[SNP$CHROM == "lg1"] <- "1"
SNP$CHR[SNP$CHROM == "lg2"] <- "2"
SNP$CHR[SNP$CHROM == "lg3"] <- "3"
SNP$CHR[SNP$CHROM == "lg4"] <- "4"
SNP$CHR[SNP$CHROM == "lg5"] <- "5"
SNP$CHR[SNP$CHROM == "lg6"] <- "6"
SNP$CHR[SNP$CHROM == "lg7"] <- "7"
SNP$CHR[SNP$CHROM == "lg8"] <- "8"
SNP$CHR[SNP$CHROM == "lg9"] <- "9"
SNP$CHR[SNP$CHROM == "lg10"] <- "10"
SNP$CHR[SNP$CHROM == "lg11"] <- "11"
SNP$CHR[SNP$CHROM == "lg12"] <- "12"
SNP$CHR[SNP$CHROM == "lg13"] <- "13"
SNP$CHR[SNP$CHROM == "lg14"] <- "14"
SNP$CHR[SNP$CHROM == "lg15"] <- "15"
SNP$CHR[SNP$CHROM == "lg16"] <- "16"
SNP$CHR<-as.numeric(SNP$CHR)


SNP2 <- makeGRangesFromDataFrame(SNP, start.field = "POS", end.field = "POS", seqnames.field = "CHR")
mcols(SNP2)$CSS <- SNP$CSS
mcols(SNP2)$PI <- SNP$PI
mcols(SNP2)$FST <- SNP$FST
mcols(SNP2)$rSB2 <- SNP$rSB2
mcols(SNP2)$PC1 <- SNP$PC1

saveRDS(SNP2,"CSS.rds")