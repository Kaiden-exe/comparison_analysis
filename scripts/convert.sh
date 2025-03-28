#!/bin/bash

source $1
module load r

mkdir -p $DEGOG
Rscript --vanilla scripts/convert.R $sonicOutput $DEGOG

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize