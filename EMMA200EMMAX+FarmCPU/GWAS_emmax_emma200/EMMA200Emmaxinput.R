geno=read.table("/home/cks/norfab/faststorage/Genotype_data_ProFaba_20201002/SNPsWithNoMissingness_OCT2020/GenericGenotypeFile.csv",head=T,sep=",")

geno_new=geno[,4:ncol(geno)]
geno_new[geno_new=="1"]<-2
geno_new[geno_new=="0"]<-1
geno_new[geno_new=="-1"]<-0

geno_new_new=cbind(geno[,2:3],geno_new)
colnames(geno_new_new)=c("# CHROM","POS",colnames(geno)[4:ncol(geno)])
write.table(geno_new_new,"GenericGenotypeFile_input.csv",quote=F,row.names=F,col.names=T,sep=",")
