geno=read.table("../GenericGenotypeFile.csv",head=T,sep=",")

geno_new=geno[,4:ncol(geno)]
geno_new[geno_new=="1"]<-2
geno_new[geno_new=="0"]<-1
geno_new[geno_new=="-1"]<-0

geno_new_new=cbind(geno[,2:3],geno_new)
colnames(geno_new_new)=c("# CHROM","POS",colnames(geno)[4:ncol(geno)])

write.table(geno_new_new,"GenericGenotypeFile_input.csv",quote=F,row.names=F,col.names=T,sep=",")
# if we don't have integers as position emma200+emmax python implementation do not work
if (length(which(geno_new_new$POS%%1!=0))>1){
	geno_new_new$POS=round(geno_new_new$POS)
	write.table(geno_new_new,"GenericGenotypeFile_input.csv",quote=F,row.names=F,col.names=T,sep=",")
}