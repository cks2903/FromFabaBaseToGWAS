conda deactivate
source ~/miniconda2/etc/profile.d/conda.sh
conda activate myproject

python /home/cks/NChain/faststorage/GWASimplementation/atgwas/src/gwa.py -o "" -a emmax -m 8 -r FN_acidity_phenotypes_avg.csv -f Fakephenotypes.csv --data_format="diploid_int"
# IF MAF=0.05 x/(156)=0.05 <=> x= 7.8		MAC=8 (because apparently this is calculated on a haploid level)