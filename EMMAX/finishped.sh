paste -d',' pedsixcol.txt intermediate.txt > pastedgenofile.txt 
sed 's/\//,/g' pastedgenofile.txt >genotypes_csv.ped
sed 's/,/ /g' genotypes_csv.ped >genotypes.ped