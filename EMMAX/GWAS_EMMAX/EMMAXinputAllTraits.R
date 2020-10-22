# Load files witn phenotypes
{
  args=commandArgs(trailingOnly = TRUE)
  Phenotypefile=read.table(args[1],sep=",",header=T)
}

# get a list of traits and accessions
Traits=colnames(Phenotypefile)[2:ncol(Phenotypefile)]
Accessions=Phenotypefile[,1]

# Load .tped file
Pre_tped=read.table("../pedsixcol.txt",sep=",",header=F)
dim(Pre_tped)
colnames(Pre_tped)=c("Accession","FAMID","Father","Mother","Sex","Phenotype")
Pre_tped$Phenotype=NULL

# loop through each trait and make a tfam file for each with unique name
for (i in seq(1:length(Traits))){
  giventrait=Traits[i]
  whichcol=which(colnames(Phenotypefile)==giventrait)
  small_df=Phenotypefile[,c(1,whichcol)]
  merged=merge(Pre_tped,small_df,by="Accession",all.x=TRUE)
  filename=paste(giventrait,"_.txt",sep="")
  write.table(merged,filename,col.names=F,row.names=F,quote=F,sep=",")
}


