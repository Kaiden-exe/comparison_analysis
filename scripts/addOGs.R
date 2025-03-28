#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st = orthogroups_converted.tsv
# 2nd = species.txt
# 3rd  = DEGOut 
# 4th = transmaps
# 5th = output

library(dplyr)
library(tidyr)

##### IMPORT DATA #####
OGs <- read.delim(args[1])

species = read.table(args[2])
species = as.vector(species[,1])


for (specie in species) {
  # Get right files 
  degs = read.delim(paste(args[3], '/', specie, "_DESeq_results.txt", sep = ""))
  transMap = read.delim(paste(args[4], "/", specie, ".gene_trans_map",
                              sep = ""), header = F)
  
  
  # Extract data
  speciesSubset = OGs[,c('Orthogroup', specie)]
  
  # Get rid of NAs and convert to long format
  speciesSubset = na.omit(speciesSubset)
  names(speciesSubset)[names(speciesSubset) == specie] <- "geneID"
  speciesSubset = separate_rows(speciesSubset, geneID, sep = ',')
  
  # Add OGs to all 
  degs$OGs = lapply(degs$geneID, function(x) {
    proteins = transMap[transMap$V1 == x,2]
    proteinOGs = speciesSubset[speciesSubset$geneID %in% proteins,]
    if ( nrow(proteinOGs) == 0) {
      OGStr = "NA"
    } else {
      uniqOG = unique(proteinOGs$Orthogroup)
      OGStr = paste(uniqOG, collapse = ",")
    }
    return(OGStr)
  })
  degs$OGs = vapply(degs$OGs, paste, collapse = ", ", character(1L))
  
  write.table(degs, file = paste(args[5], "/", specie, "_DEG_OG.tsv", sep = ""),
              sep = "\t", row.names = F, quote = F, na = "NA")
}