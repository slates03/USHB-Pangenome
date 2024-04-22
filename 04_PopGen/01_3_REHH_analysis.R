#--------------------
# IHS and Scan Scores
#--------------------


library(rehh)

#list the files
fl.ls <- list.files(pattern = ".vcf", full.names = F)

ihs_df <- c()
scan_df <- c()

for(i in 1:16){

hap_file <- fl.ls[i]

hh_vcf <- rehh::data2haplohh(hap_file = hap_file,
                       vcf_reader = "data.table",
                       verbose = FALSE,
                       polarize_vcf = FALSE)


scan <- scan_hh(hh_vcf, discard_integration_at_border = FALSE, polarized = FALSE)
ihs <- ihh2ihs(scan, freqbin = 1)
ihs_x<-data.frame(ihs$ihs)

scan_df<- rbind(scan,scan_df)
ihs_df <- rbind(ihs_x,ihs_df)

}


write.table(ihs_df,"ihs_df")
write.table(scan_df,"scan_df")


#--------------------
# RSB
#--------------------

ies2rsb<-function(hh_pop1,hh_pop2,popname1=NA,popname2=NA,method="bilateral"){

  ies_1=hh_pop1[,6] ; ies_2=hh_pop2[,6]
  if(!(nrow(hh_pop1)==nrow(hh_pop2))){stop("hh_pop1 and hh_pop2 must have the same dimensions")}
  if(sum(hh_pop1[,2]==hh_pop2[,2])<nrow(hh_pop1)){stop("SNP position in hh_pop1 and hh_pop2 must be the same")}
  tmp_rsbnc=log(ies_1/ies_2) ; tmp_med=median(tmp_rsbnc,na.rm=T) ; tmp_sd=sd(tmp_rsbnc,na.rm=T)
  rsbcor=(tmp_rsbnc-tmp_med)/tmp_sd
  tmp_pval=rsbcor*0
  if(method=="bilateral"){tmp_pval=-1*log10(1-2*abs(pnorm(rsbcor)-0.5))}
  if(method=="unilateral"){tmp_pval=-1*log10(1-pnorm(rsbcor))}
  tmp_pval2=tmp_pval ; tmp_pval2[tmp_pval2=="Inf"]=NA  
  tmp_pval[tmp_pval=="Inf"]=max(tmp_pval2,na.rm=TRUE) + 1 
  res.rsb=cbind(hh_pop1[,1:2],rsbcor,tmp_pval)
  colnames(res.rsb)[3]=paste("rSB (",popname1," vs ",popname2,")",sep="")
  colnames(res.rsb)[4]=paste("Pvalue (",method,")",sep="")

  return(list(res.rsb=res.rsb))
}


polline_scan=read.table("pol_scan_df")
polline_scan=polline_scan[,c(1,2,3,7,8,9)]

kona_scan=read.table("kona_scan_df")
kona_scan=kona_scan[,c(1,2,3,7,8,9)]

hilo_scan=read.table("hilo_scan_df")
hilo_scan=hilo_scan[,c(1,2,3,7,8,9)]

idx_p<-polline_scan[,c(1,2)]
idx_k<-kona_scan[,c(1,2)]
idx_h<-hilo_scan[,c(1,2)]
idx<-merge(idx_p,idx_k)
idx<-merge(idx,idx_h)

polline_scan<-merge(polline_scan,idx,by=c("CHR","POSITION"))
kona_scan<-merge(kona_scan,idx,by=c("CHR","POSITION"))
hilo_scan<-merge(hilo_scan,idx,by=c("CHR","POSITION"))

#Pol Versus Kona
rsb.gahbxahb <- ies2rsb(polline_scan, kona_scan, "polline", "kona")
rsb_pol_kona<-data.frame(rsb.gahbxahb$res.rsb)
colnames(rsb_pol_kona)<-c("CHR","POSITION","rSB","Pvalue")
write.table(rsb_pol_kona,"rsb_pol_kona.txt")

#Pol Versus hilo
rsb.gahbxahb <- ies2rsb(polline_scan, hilo_scan, "polline", "hilo")
rsb_pol_hilo<-data.frame(rsb.gahbxahb$res.rsb)
colnames(rsb_pol_hilo)<-c("CHR","POSITION","rSB","Pvalue")
write.table(rsb_pol_hilo,"rsb_pol_hilo.txt")

#kona Versus hilo
rsb.gahbxahb <- ies2rsb(kona_scan, hilo_scan, "kona", "hilo")
rsb_kona_hilo<-data.frame(rsb.gahbxahb$res.rsb)
colnames(rsb_kona_hilo)<-c("CHR","POSITION","rSB","Pvalue")
write.table(rsb_kona_hilo,"rsb_kona_hilo.txt")




