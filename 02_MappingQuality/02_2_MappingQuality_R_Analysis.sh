
config<-read.table("/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/src/sample.txt")
config <- as.character(config[,1], quote="'")

setwd("/90daydata/virus_rnaseq/2022_WGS_drone_stock/drone_samples/data/02B_vgBAMS/vg_stats")

align<-c()
for(bee in config){

#Data
ID<-bee
total<-paste(bee,"vg_all_align.txt",sep="_")
x<-read.table(total)
total2<-paste(bee,"vg_perfect_align.txt",sep="_")
x2<-read.table(total2)
total3<-paste(bee,"vg_mq60.txt",sep="_")
x3<-read.table(total3)


final<-cbind(ID,x,x3,x2)
colnames(final)<-c("ID","reads","perfect","mq60")

align<-rbind(align,final)
}

write.table(align,"align.txt")

