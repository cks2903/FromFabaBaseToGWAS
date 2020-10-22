library(dplyr)

geno1=read.table("../GenericGenotypeFile.csv",head=T,sep=",")

tgeno1=t(geno1)

SNPnames=geno1[,1]
length(SNPnames)

# Delete chr, pos, identifier and gene row
tgeno2=tgeno1[4:(nrow(tgeno1)),]

tgeno2df=as.data.frame(tgeno2)
tgeno3 <- tibble::rownames_to_column(tgeno2df, "Taxa") # make accession names first column instead of row.names

colnames(tgeno3)=SNPnames

write.table(tgeno3,"Genotypes_FarmCPU.txt",sep="\t",quote=F,col.names=T,row.names=F) # that is the GD file


# now make the GM table also with SNP information
GMtable=cbind(as.character(geno1$SNP),geno1$CHR,geno1$POS)
colnames(GMtable)=c("Name","Chromosome","Position")
write.table(GMtable,"GenotypeInfo_FarmCPU.txt",sep="\t",quote=F,col.names=T,row.names=F) # that is the GM file



