#!/bin/bash

source $1

module load blast

makeblastdb -in $proteomeFile -dbtype prot -parse_seqids -out $modelDB/$modelID

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize


