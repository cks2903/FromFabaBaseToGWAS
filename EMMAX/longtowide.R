# a script to reshape the genotype data outputtet by mysql

# load libraries
library(tidyr)

# Load data
extremelylargetable <- read.csv("genotypes.txt",sep='\t',head=F)
colnames(extremelylargetable)=c("GenotypingDate","GenotypeCall","Genotyping_Comments","SNPIdentifier","ProbeSetID","Start","Strand","Gene","Annotation","Chromosome","Position","CallRate","FLD","HetSO","HomRO","GenotypingPlatform","SNP_Comments","Name","AlternativeName","Donor","GeographicOrigin","Maintaining","Germplasm_Comments")
extremelylargetable=as.data.frame(extremelylargetable)
# convert table from long t
print(paste("This many unique seed lot ids:",length(unique(extremelylargetable$Name)),sep=" "))
print("starting pivot conversion")

extremelylargetable$AlternativeName=NULL
extremelylargetable$Donor=NULL
extremelylargetable$GeographicOrigin=NULL
extremelylargetable$Maintaining=NULL
extremelylargetable$Germplasm_Comments=NULL


wide_DF <- extremelylargetable %>% spread("Name", "GenotypeCall")
head(wide_DF) 

firsthalf_wide_DF=wide_DF[,1:16]
secondhalf_wide_DF=wide_DF[,17:ncol(wide_DF)]
firsthalf_wide_DF[firsthalf_wide_DF=="\\N"]="NA"
secondhalf_wide_DF <- data.frame(lapply(secondhalf_wide_DF, as.character), stringsAsFactors=FALSE)
secondhalf_wide_DF[secondhalf_wide_DF=="\\N"]=as.character("NA/NA")
combined=cbind(firsthalf_wide_DF,secondhalf_wide_DF)

write.table(combined,"Genotypefile.csv",col.names=T,row.names=F,quote=F,sep=";")



