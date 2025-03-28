# Author: Kaiden R. Sewradj

# Project directory
DIR=/shared/projects/tardi_genomic

### INPUT ###
sonicOutput=$DIR/deg/sewradj/pipelines/orthology_v1/sonicparanoid_results/runs/tardi_genomic_20250220120242/ortholog_groups/ortholog_groups.tsv
species=species_subset.txt
DEGout=DEG_out
transmaps=transmaps
emapperOut=emapper_out
GO_OBO=go.obo

# Alternative annotation
modelID=Cele
proteomeFile=Cele_proteome.fasta
modelDB=CeleDB
modelAnnot=Cele_annot

### OUTPUT ###
DEGOG=DEG_OG
GOout=GO_enrichment
