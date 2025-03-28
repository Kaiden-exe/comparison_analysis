#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st = ortholog_groups.tsv 
# 2nd = species.txt
# 3rd  = DEGOut 
# 4th = transmaps
# 5th = output

library(dplyr)
library(tidyr)

##### IMPORT DATA #####
OGs <- read.delim(args[1], comment.char="#", na.strings="*")
colnames(OGs) = gsub(".fasta", "", colnames(OGs))

species = read.table(args[2])
species = as.vector(species[,1])

deg_og = OGs[, c("group_id", "group_size")]


for (specie in species) {
  # Get right files 
  degs = read.delim(paste(args[3], '/', specie, "_DESeq_results.txt", sep = ""))
  transMap = read.delim(paste(args[4], "/", specie, ".gene_trans_map",
                              sep = ""), header = F)
  
  # Filter out DEGs
  degs = degs[degs$pvalue <= 0.05,]

  # Get all proteins
  proteins = transMap[transMap$V1 %in% degs$geneID,2]

  deg_og$NewCol = lapply(deg_og$group_id, function(x) {
    proteinStr = OGs[OGs$group_id == x, c(specie)]
    proteinsOG = unlist(strsplit(proteinStr, ","))
    proteinsDEG = proteinsOG[proteinsOG %in% proteins]

    return(length(proteinsDEG))
  })
  
  deg_og$NewCol = as.integer(deg_og$NewCol)
  names(deg_og)[names(deg_og) == "NewCol"] <- paste(specie, "DEG_cnt", sep="_")
}

# Calculate DEG% 
columns = paste(species, 'DEG_cnt', sep='_')
deg_og$DEG_pct = lapply(deg_og$group_id, function(x){
  totalDEG = sum(unlist(as.vector(deg_og[deg_og$group_id == x, columns])))
  grp_size = as.numeric(deg_og[deg_og$group_id == x, c("group_size")])
  pct = totalDEG / grp_size
  return(pct)
})

deg_og$DEG_pct = unlist(deg_og$DEG_pct)

write.table(deg_og, file=paste(args[5], "DEG_pct.tsv", sep="/"), sep = "\t", quote = F, row.names = F)
