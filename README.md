# FromFabaBaseToGWAS


# workflow for generating genotypes for GWAS directly from database output

# Step 0 takes place in the mysql database.
# Step 1-9 takes place on the GenomeDK cluster
# The local environments needed are "Rprogram" which contains R with all dependencies installed, and "myproject" which contains python 2 installed
################################################################
########################	  STEP 0 	    ########################
################################################################
################################################################
# Get output needed from database				                      ##
################################################################

SELECT NorGT.GenotypingDate,NorGT.GenotypeCall,NorGT.Comment,NorSN.SNPIdentifier,NorSN.ProbeSetID,NorSN.Start,NorSN.Strand,NorSN.Gene,NorSN.Annotation,NorSN.Chromosome,NorSN.Position,NorSN.CallRate,NorSN.FLD,NorSN.HetSO,NorSN.HomRO,NorSN.GenotypingPlatform,NorSN.Comment,NorGP.Name,NorGP.AlternativeName,NorGP.Donor,NorGP.GeographicOrigin,NorGP.Maintaining,NorGP.Comments
FROM NorGT,NorSN,NorSL,NorGP
WHERE NorGT.SNID=NorSN.SNID
AND NorGT.SLID=NorSL.SLID
AND NorGP.GPID=NorSL.GPID
INTO OUTFILE "/Users/CathrineKiel/Desktop/genotypes.txt";


################################################################
########################	   STEP 1 	  ########################
################################################################
################################################################
# convert from long format to wide format			                ##
################################################################

source ~/miniconda3/etc/profile.d/conda.sh
conda activate Rprogram
qx --no-scratch -c 10 --mem=250g Rscript longtowide.R 


################################################################
########################	    STEP 1  	########################
################################################################
################################################################
# Make .ped and .map file that can be plink input.            ##
################################################################

qx --no-scratch -c 10 --mem=16g Rscript MakePedAndMapFile.R 0.1 
# the last number is the missingness filter you want for SNPs
# put 1.0 if you don't want a missingness filter, but be aware that 
# the missing genotype might be mistaken for an allele by plink then

# finish the .ped file using unix commands, this is way quicker than R!
./finishped.sh


################################################################
########################	   STEP 2 	  ########################
################################################################
################################################################
# 			Use plink to make numeric genotype file 		          ##
################################################################

./plinkGenotypeConv.sh


################################################################
########################	    STEP 3 	  ########################
################################################################
################################################################
# 			    Convert genotypes to a -1,0,1 format		          ##
#			      with only one value pr. genotype   		            ##
################################################################

source activate myproject
qx --no-scratch -c 10 --mem=16g python MakeGenofileReadyforGRM.py  "genotypes_numeric.tped"


################################################################
########################	    STEP 4 	  ########################
################################################################
################################################################
# 			Make a typical genotype file		                      ##
#			columns: CHR, POS, IND1, IND2 etc.		                  ##
################################################################

./MakeGenericGenotypefile.sh


################################################################
########################	    STEP 5 	  ########################
################################################################
################################################################
# 			Make a GRM using VanRaden method 1 		                ##
################################################################

conda deactivate
qx --no-scratch --mem=100g Rscript MakeGRM.R "GenotypeFileForGRM.csv"

################################################################
########################	    STEP 6 	  ########################
################################################################
################################################################
# 			Display relationship in heatmap		                    ##
################################################################

qx --no-scratch --mem=100g Rscript Heatmap_from_GRM.R "GRM_5percMAFfilter.csv"


################################################################
########################	    STEP 7 	  ########################
################################################################
################################################################
# 			Do FastSTRUCTURE on population to see 			          ##
# 			number of clusters	              				            ##
################################################################

./Get_FastStructure.sh

################################################################
########################	    STEP 8  	########################
################################################################
################################################################
# 					GWAS prepare all phenotypes				                ##
#					 Use all SNPs both mapped and not                   ##
################################################################

cd GWAS_EMMAX

qx --no-scratch --mem=100g Rscript EMMAXinputAllTraits.R "Fakephenotypes.csv"

./Traitprep.sh #makes a .ped file for each trait

################################################################
########################	      STEP 9 	########################
################################################################
################################################################
# 					                  EMMAX GWAS			  				      ##
#					           Use all SNPs both mapped and not         ##
################################################################

./RunGWAS_AllTraits.sh   

