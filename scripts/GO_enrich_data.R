#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = species.txt
# 2nd = directory with .annotations files
# 3rd = outdir 
# 4th = go.obo

library(tidyr)
library(dplyr)
library(ontologyIndex, lib = "/shared/projects/tardi_genomic/bin/Rlibs")

allSpecies = read.table(args[1])
allSpecies = as.vector(allSpecies[,1])

#### STEP 1 ####
# Term to gene table 
TERM2GENE = NULL
for (species in allSpecies) {
  annotFile = paste(args[2], "/", species, ".emapper.annotations", sep="")
  annotFile = read.delim(annotFile, header = F, comment.char = "#",
                         na.strings = "-")
  
  colnames(annotFile) = c('query','seed_ortholog','evalue','score',
                          'eggNOG_OGs','max_annot_lvl','COG_category',
                          'Description','Preferred_name','GOs','EC','KEGG_ko',
                          'KEGG_Pathway','KEGG_Module','KEGG_Reaction',
                          'KEGG_rclass','BRITE','KEGG_TC','CAZy',
                          'BiGG_Reaction','PFAMs')
  gene2term = annotFile[,c('query', 'GOs')]
  gene2term = separate_rows(gene2term, GOs, sep = ',')
  TERM2GENE = rbind(TERM2GENE, gene2term)
}

TERM2GENE = na.omit(TERM2GENE)
TERM2GENE = TERM2GENE[,c(2,1)]
colnames(TERM2GENE) = c('term', 'gene')

write.table(TERM2GENE, file=paste(args[3], "/", "TERM2GENE.tsv", sep=""),
            sep = '\t', row.names = F)

##### STEP 2 ####
# Term to name table 
ontology = get_ontology(file = args[4], extract_tags = "everything")
TERM2NAME = mutate(TERM2GENE, name=ontology$name[term])
TERM2NAME$gene = NULL
TERM2NAME = distinct(TERM2NAME)
TERM2NAME = na.omit(TERM2NAME)
write.table(TERM2NAME, file=paste(args[3], "/", "TERM2NAME.tsv", sep=""),
            sep = '\t', row.names = F)