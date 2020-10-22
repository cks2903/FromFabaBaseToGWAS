# FromFabaBaseToGWAS

##Workflow for generating genotypes for GWAS directly from database output
## This setup is for SNPs with no missingness as it implements three different versions of GWAS: EMMAX, EMMA200+EMMAX and FarmCPU from GAPIT

##Step 0 takes place in the mysql database.

##Step 1-12 takes place on the GenomeDK cluster

##The local environments needed are "Rprogram" which contains R with all dependencies installed, and "myproject" which contains python 2 installed with the following version of numpy: 1.11.3 and the following version of scipy: 1.2.0.

##Activate all .sh scripts by typing chmod u+x name.sh 

# STEP 0: Get output needed from database				       
SELECT NorGT.GenotypingDate,NorGT.GenotypeCall,NorGT.Comment,NorSN.SNPIdentifier,NorSN.ProbeSetID,NorSN.Start,NorSN.Strand,NorSN.Gene,NorSN.Annotation,NorSN.Chromosome,NorSN.Position,NorSN.CallRate,NorSN.FLD,NorSN.HetSO,NorSN.HomRO,NorSN.GenotypingPlatform,NorSN.Comment,NorGP.Name,NorGP.AlternativeName,NorGP.Donor,NorGP.GeographicOrigin,NorGP.Maintaining,NorGP.Comments
FROM NorGT,NorSN,NorSL,NorGP
WHERE NorGT.SNID=NorSN.SNID
AND NorGT.SLID=NorSL.SLID
AND NorGP.GPID=NorSL.GPID
INTO OUTFILE "/Users/CathrineKiel/Desktop/genotypes.txt";


# STEP 1: Convert from long format to wide format

source ~/miniconda3/etc/profile.d/conda.sh

conda activate Rprogram

qx --no-scratch -c 10 --mem=250g Rscript longtowide.R 


# STEP 2: Make .ped and .map file that can be plink input

qx --no-scratch -c 10 --mem=16g Rscript MakePedAndMapFile.R 0.0 

#the last number is the missingness filter you want for SNPs
#set missingness filter to 0 as we don't want the markers with missingness 

#Then finish the .ped file using unix commands, this is way quicker than R!

./finishped.sh


# STEP 3: Use plink to make numeric genotype file 

./plinkGenotypeConv.sh


# STEP 4: Convert genotypes to a -1,0,1 format with only one value pr. genotype   	

source activate myproject

qx --no-scratch -c 10 --mem=16g python MakeGenofileReadyforGRM.py  "genotypes_numeric.tped"


# STEP 5: Make a typical genotype file w. columns: CHR, POS, IND1, IND2 etc.		             

./MakeGenericGenotypefile.sh


# STEP 6: Make a GRM using VanRaden method 1 

conda deactivate

qx --no-scratch --mem=100g Rscript MakeGRM.R "GenotypeFileForGRM.csv"

# STEP 7: Display relationship in heatmap		

qx --no-scratch --mem=100g Rscript Heatmap_from_GRM.R "GRM_5percMAFfilter.csv"


# STEP 8: Do FastSTRUCTURE on population to see number of clusters

./Get_FastStructure.sh

# STEP 9: GWAS prepare all phenotypes, use only mapped SNPs

cd GWAS_EMMAX

qx --no-scratch --mem=100g Rscript EMMAXinputAllTraits.R "Fakephenotypes.csv"

./Traitprep.sh #makes a .ped file for each trait

# STEP 10: EMMAX GWAS, use only mapped SNPs

./RunGWAS_AllTraits.sh   

# STEP 11: EMMA2000+EMMAX GWAS,use only mapped SNPs

cd GWAS_emmax_emma200

qx --no-scratch Rscript EMMA200Emmaxinput.R

./RUN_EMMA200EMMAX200.sh

# STEP 12: GAPIT FarmCPU GWAS,use only mapped SNPs

cd GWAS_FarmCPU

#Make genotype files ready
conda deactivate 
source ~/miniconda3/etc/profile.d/conda.sh
conda activate Rprogram
qx --no-scratch --mem=100g Rscript MakeFarmCPUinput.R 

#Run provide comma-sep pheno-file as input
qx --no-scratch -c 60 Rscript FarmCPU_ParallelMultiTraits.R "Fakephenotypes.csv"

