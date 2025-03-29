# 1st argument: transdecoder folder
# 2nd argument: output folder

# Just for results from the pipeline
for speciesDir in $1/*/; do
    species=$(basename "$speciesDir")
    pepFile=$speciesDir/${species}.Trinity-GG.fasta.transdecoder.pep
    mapFile=$2/$species.gene_trans_map
    tempFile=$2/$species.gene_trans_map_temp

    grep '>' $pepFile | cut -f1 -d " " | cut -c2- > $tempFile

    while read LINE ; do
        gene=${LINE%_i*}
        echo -e "$gene\t$LINE" >> $mapFile
    done <"$tempFile"

    rm $tempFile
done
