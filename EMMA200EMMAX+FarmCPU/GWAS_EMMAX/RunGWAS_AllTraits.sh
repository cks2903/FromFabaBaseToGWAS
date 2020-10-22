source GWAS_run.sh


# get a list of traits

for TRAIT in ls *_.ped
do
	y=${TRAIT%.ped}
	./GWAS_run.sh "${y}" "../genotypes.map"
done