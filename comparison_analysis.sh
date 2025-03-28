#!/bin/bash

# Author: Kaiden R. Sewradj

############################
########## CHECKS ##########
############################
while [ $# -gt 0 ]; do
	case $1 in
    #TODO
		-h | --help)
			echo "Follow instructions in the template configuration file."
			echo "Then run bash comparison_analysis.sh -c config.sh"
			exit 0
        ;;
		-c | --config)
			if [ ! -f "$2" ]; then
				echo "Configuration file not found" >&2
				exit 1
			fi

			configFile=$2
			shift
		;;
		*)
			echo "Invalid option: $1" >&2
			exit 1
		;;
    esac
	shift
done

if [ ! -f "$configFile" ]; then
	echo "ERROR: Configuration file $configFile not found" >&2
	exit 1
fi

source $configFile

# Check files and directories
if [ ! -f  $species ] ; then
	echo "ERROR: $species file not found." >&2
	exit 1
fi

if [ ! -d $DEGout ] || [ $(ls $DEG_out | wc -l) -lt 1 ] ; then
	echo "ERROR: $DEGout directory either does not exist or is empty"
	exit 1
fi

if [ ! -d $transmaps ] || [ $(ls $transmaps | wc -l) -lt 1 ] ; then
	echo "ERROR: $transmaps directory either does not exist or is empty"
	exit 1
fi

# Sonicparanoid output if not done yet
if [ ! -f "$DEGOG/orthogroups_converted.tsv" ] ; then
	job0=$(sbatch -J convert -N 1 --mem=32G -n 16 -o logfiles/convert.%A.out -e logfiles/convert.%A.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/convert.sh $configFile)
	jobID0=${job0##* }
	echo "Converting sonicparanoid output job $jobID0"
else
	jobID0=-1
fi

# Add OGs to DEGs
if [[ "$jobID0" -eq -1 ]] ; then 
	job1=$(sbatch -J deg_og -N 1 --mem=32G -n 16 -o logfiles/deg_og.%A.out -e logfiles/deg_og.%A.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/addOGs.sh $configFile)
else 
	job1=$(sbatch -J deg_og -N 1 --mem=32G -n 16 -o logfiles/deg_og.%A.out -e logfiles/deg_og.%A.error -A tardi_genomic -p fast -t 0-23:00:00 --dependency=afterok:${jobID0} scripts/addOGs.sh $configFile)
fi

jobID1=${job1##* }
echo "Adding OGs to DEG tables job $jobID1"

# Calculate DEGs per cluster
job2=$(sbatch -J deg_clstr -N 1 --mem=32G -n 16 -o logfiles/deg_per_cluster.%A.out -e logfiles/deg_per_cluster.%A.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/degs_per_cluster.sh $configFile)
jobID2=${job2##* }
echo "Calculating DEGs per cluster job $jobID2"

# GO term enrichment 
job3=$(sbatch -J GO_data -N 1 --mem=64G -n 32 -o logfiles/GO_data.%A.out -e logfiles/GO_data.%A.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/GO_enrich_data.sh $configFile)
jobID3=${job3##* }
echo "GO term data preparation job $jobID3"

job4=$(sbatch -J GO_enrich -N 1 --mem=64G -n 32 -o logfiles/GO_enrich.%A.out -e logfiles/GO_enrich.%A.error -A tardi_genomic -p fast -t 0-23:00:00 --dependency=afterok:${jobID3} scripts/clusterProfiler.sh $configFile)
jobID4=${job4##* }
echo "GO term enrichment analysis job $jobID4"

# Alternative annotation
# Annotate model if not done already 
if [ ! -f "$modelAnnot/${modelID}.emapper.annotations" ] ; then
	


# Skip making DB if it already exists 
if [ ! -f "$modelDB/${modelID}.pdb" ] ; then
	job6=$(sbatch -J blastp -N 1 -n 6 --mem=16G -o logfiles/blastdb.%A_%a.out -e logfiles/blastdb.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/makedb.sh $configFile)
	jobID6=${job6##* }
	echo "Creating BLASTdb for $modelID job $jobID6"
else
	jobID6=-1
fi

