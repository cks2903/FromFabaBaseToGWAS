# create .ped files for each trait

for TRAIT in ls *_.txt
do
	paste -d ',' "$TRAIT" ../intermediate.txt > outputfile.txt
	echo "working on $TRAIT"
	sed 's/\//,/g' outputfile.txt >outputfile.ped
	sed 's/,/ /g' outputfile.ped >outputfile_.ped
	mv outputfile_.ped "$TRAIT"
done

# give the files the suffix .ped
for TRAIT in ls *_.txt
do
	mv -- "$TRAIT" "${TRAIT/%.txt/.ped}"
done

