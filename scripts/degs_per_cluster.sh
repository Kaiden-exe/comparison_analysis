#!/bin/bash

source $1
module load r

mkdir -p $DEGOG
Rscript --vanilla scripts/degs_per_cluster.R $sonicOutput $species $DEGout $transmaps $DEGOG

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
