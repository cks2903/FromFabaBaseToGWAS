# Load librariries
{
  library(tidyverse)
  args=commandArgs(trailingOnly = TRUE)
}


# Load files needed
{
  genotypes=read.csv("Genotypefile.csv",sep=";",head=T,stringsAsFactors=FALSE)

}

# print info
{
  number_of_SNPs=nrow(genotypes)
  print(paste("Individuals are genotyped for",number_of_SNPs,"markers",sep=" "))
  
  MappedSNPs=length(which(genotypes$Position!="NA"))
  print(paste("Out of",number_of_SNPs,"markers,",MappedSNPs,"has been mapped. That is:",round(MappedSNPs/number_of_SNPs,2)*100,"%" ,sep=" "))
  
  IndividualNumber=ncol(genotypes)-16
  print(paste(IndividualNumber,"individuals found",sep=" "))
  
}


# if wanted remove SNPs with a missingness above given threshold
{  
  threshold_missingness=as.numeric(as.character(args[1]))
  markerswithmissingness=data.frame()

  for (snp in seq(1:nrow(genotypes))){
    Ind_withNA=length(which(genotypes[snp,17:(IndividualNumber+16)]=="NA/NA"))
    missingness=Ind_withNA/IndividualNumber
    if (missingness>threshold_missingness){
      df = data.frame(genotypes[snp,3],as.numeric(as.character(missingness)))
      markerswithmissingness =rbind(markerswithmissingness,df)
    }
  }
  print(paste("Removed",nrow(markerswithmissingness),"markers because of missingness >",threshold_missingness,sep=" "))
  if (nrow(markerswithmissingness)!=0){
    idx_to_remove=which(genotypes[,3] %in% markerswithmissingness[,1])
    newgenotype=genotypes[-idx_to_remove,]
    print(paste(nrow(newgenotype),"markers left",sep=" "))
  }
}

# Make the .map file where all markers with no mapping info is just added as non-existing chr7 in the end
{
  Chr=newgenotype[,9]
  pos_total=newgenotype[,10]
  variant_id=newgenotype[,3]
  
  pos_total_noNa=pos_total[-which(is.na(pos_total)==T)]
  pos_total_noNa=as.numeric(as.character(pos_total_noNa))
  endingpos=max(pos_total_noNa)

  snps_with_no_mapping=which(is.na(Chr)==T)
  currentposition=endingpos+3
  for (i in snps_with_no_mapping){
    Chr[i]=as.character("7")
    pos_total[i]=currentposition
    currentposition=currentposition+1
  }
  Map=cbind(Chr,as.character(variant_id),pos_total,pos_total)
  Map=as.data.frame(Map)
  
  #order map so it is in position order
  map_ordered=Map[with(Map,order(as.numeric(as.character(Chr)),as.numeric(as.character(pos_total)))),]

  write.table(map_ordered,file="genotypes.map",sep="\t",col.names=F,row.names=F,quote = F)
}


# Make and output what is needed for .ped file
{
  # order newgenotype file so SNPs are in the same order as in map file
  target <- map_ordered$V2
  newgenotype_ordered=newgenotype[match(target, newgenotype$SNPIdentifier),]


  if (all(newgenotype_ordered$SNPIdentifier==map_ordered$V2)){
    dummycolumn=rep(0,IndividualNumber)
    accessionnames=colnames(newgenotype_ordered)[17:(ncol(newgenotype_ordered))]
    ped_six_columns=cbind(accessionnames,accessionnames,dummycolumn,dummycolumn,dummycolumn,dummycolumn)
    onlygenotypes=newgenotype_ordered[,17:ncol(newgenotype_ordered)]
    only_genotypes_T=t(onlygenotypes)


    if (nrow(only_genotypes_T)==nrow(ped_six_columns)){
      write.table(only_genotypes_T,file="intermediate.txt",sep=",",col.names=F,row.names=F,quote = F)
      write.table(ped_six_columns,file="pedsixcol.txt",sep=",",col.names=F,row.names=F,quote=F)
      }
  }
}

