#!/bin/bash
#SBATCH -J eggnog-mapper
#SBATCH -n 4 
#SBATCH --mem=250G
#SBATCH -o logfiles/worm_annot.%A.out
#SBATCH -e logfiles/worm_annot.%A.error
#SBATCH -A tardi_genomic
#SBATCH -p fast
#SBATCH -t 0-23:00:00

# Author: Kaiden R. Sewradj
# Last update: 10/03/2025

module load eggnog-mapper/2.1.12
pepFile=uniprotkb_proteome_UP000001940_2025_03_11.fasta

start=$EPOCHREALTIME
emapper.py -i $pepFile --itype proteins -o ./worm_annot --cpu 24 --data_dir /shared/bank/emapperdb/5.0.2 --sensmode ultra-sensitive --override

# Logging 
end=$EPOCHREALTIME
runtime=$( echo "$end - $start" | bc -l )
HOURS=$(echo "$runtime / 3600" | bc)
MINS=$(echo "($runtime / 60) % 60" | bc)
SECS=$(echo "$runtime % 60" | bc)
echo "Annotation of C. elegans lasted ${HOURS}hrs ${MINS}mins ${SECS%.*}secs"
echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize