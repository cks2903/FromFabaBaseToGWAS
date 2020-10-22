# make phenotype file
#the trait = $1
# the map file named genotypes.map = $2

echo "trait is: $1"

ped=".ped"
pedfile="$1${ped}"

phen=".phen"
phenfile="$1${phen}"

map=".map"
mapfile="$1${map}"

mapfile_old = $2
echo "this is the old map file: $2"


echo "You are creating ${mapfile}"
cp "$2" "${mapfile}"


# convert .map and .ped files to .tped and .tfam
source /com/extra/plink/1.90-beta-2016-03/load.sh
plink --file $1 --recode12 --prune --allow-no-sex --nonfounders --maf 0.05 --output-missing-genotype 0  --output-missing-phenotype 'NA' --transpose --out $1


# create phenotype file
tfam=".tfam"
tfamfile="$1${tfam}"

echo "You are creating ${phenfile}"
cat "${tfamfile}" | cut -d" " -f1,2,6 > "${phenfile}"


# Let emmax calculate kinship
source /com/extra/emmax/20170411/load.sh
emmax_kin -v -s -x -d 10 "$1"

# real emmax
kin=".aIBS.kinf"
kinship="$1${kin}"
emmax -v -d 10 -t "$1" -k "${kinship}" -p "${phenfile}" -o "$1"
