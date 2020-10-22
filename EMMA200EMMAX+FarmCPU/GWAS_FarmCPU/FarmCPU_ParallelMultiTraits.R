args=commandArgs(trailingOnly = TRUE)

# Load additional packages not loaded by GAPIT
library(foreach)
library(doParallel)

# GWAS using the FarmCPU implemented in GAPIT

source("http://zzlab.net/GAPIT/GAPIT.library.R")
source("http://zzlab.net/GAPIT/gapit_functions.txt")


# Function to do GAPIT GWAS, one at a time
GP_GBLUP<-function(column){
	myGAPIT <- GAPIT(
	Y=myY[,c(1,column)], #fist column is individual ID, the third columns is days to pollination 
	GD=myGD,
	GM=myGM,
	PCA.total=3,
	model="FarmCPU",
	SNP.MAF=0.05)
}
print("GAPIT function loaded")


# Import data
myY <- read.table(args[1], head = TRUE, sep=",") # Load phenotypes
print("Phenotypes loaded")
myGD <- read.table("Genotypes_FarmCPU.txt", head = TRUE) # Load genotypes, missingness is not allowed
print("Genotypes loaded")
myGM <- read.table("GenotypeInfo_FarmCPU.txt", head = TRUE)
print("Genotype information loaded")


print("Starting parallelization")
registerDoParallel(60)  # use multicore, set to the number of our cores
foreach (i=2:ncol(myY)) %dopar% {
  GP_GBLUP(i)
}


