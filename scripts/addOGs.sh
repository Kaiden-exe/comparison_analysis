#!/bin/bash

source $1
module load r

mkdir -p $DEGOG
Rscript --vanilla scripts/addOGs.R "$DEGOG/orthogroups_converted.tsv" $species $DEGout $transmaps $DEGOG

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
