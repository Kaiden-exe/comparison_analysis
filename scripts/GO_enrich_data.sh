#!/bin/bash

source $1
module load r

mkdir -p $GOout
Rscript --vanilla scripts/GO_enrich_data.R $species $emapperOut $GOout $GO_OBO

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
