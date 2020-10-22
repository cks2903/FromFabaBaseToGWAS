source /com/extra/plink/1.90-beta-2016-03/load.sh

plink --file genotypes --make-bed --nonfounders --out BedFileForStructure

cat BedFileForStructure.fam | cut -d" " -f1 > names.txt

conda activate '/home/cks/miniconda2/envs/myproject'


# number of populations equal 2
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/structure.py -K 2 --input=BedFileForStructure --output=structure

# number of populations equal 3
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/structure.py -K 3 --input=BedFileForStructure --output=structure

# number of populations equal 4
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/structure.py -K 4 --input=BedFileForStructure --output=structure

# number of populations equal 5
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/structure.py -K 5 --input=BedFileForStructure --output=structure

# Choose which one fits best
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/chooseK.py --input=structure

# drawing plotst
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/distruct.py -K 2 --input=structure --output=structure2.pdf
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/distruct.py -K 3 --input=structure --output=structure3.pdf
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/distruct.py -K 4 --input=structure --output=structure4.pdf
python /home/cks/norfab/faststorage/Genotype_Data_20200320/fastStructure/fastStructure/distruct.py -K 5 --input=structure --output=structure5.pdf
