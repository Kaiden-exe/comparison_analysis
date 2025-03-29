#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = GO_enrichment
# 2nd = DEG_out
# 3rd = transmaps 

library(tidyr)
library(clusterProfiler)
library(enrichplot)
library(ggplot2)

#### IMPORT DATA ####
TERM2GENE = read.delim(paste(args[1], "/TERM2GENE.tsv", sep=""))
TERM2NAME = read.delim(paste(args[1], "/TERM2NAME.tsv", sep=""))

# Filter out DEGs
species2Gene = as.data.frame(unique(TERM2GENE$gene))
colnames(species2Gene) = c("gene")
species2Gene = separate_wider_delim(data = species2Gene, cols = gene, 
                                    delim = "|", names = c("species"),
                                    too_many = "drop", cols_remove = F)

deg_set = NULL
allSpecies = unique(species2Gene$species)

for (species in allSpecies) { 
  degs = read.delim(paste(args[2], '/', species, "_DESeq_results.txt", sep = ""))
  transMap = read.delim(paste(args[3], "/", species, ".gene_trans_map",
                              sep = ""), header = F)
  
  # Filter out DEGs
  degs = degs[degs$pvalue <= 0.05,]
  
  # Get all proteins
  proteins = transMap[transMap$V1 %in% degs$geneID,2]
  
  deg_set = rbind(deg_set, species2Gene[species2Gene$gene %in% proteins,])
}

# Enrichment analysis
p = compareCluster(gene~species, fun="enricher", data=deg_set, 
                    TERM2GENE=TERM2GENE, TERM2NAME=TERM2NAME)
dplot = dotplot(p)

# Save 
ggsave(paste(args[1], "/", "dotplot.png", sep=""), width=1200, height=2000,
       units = "px", plot = dplot)
save.image(file = paste(args[1], "/", "clusterProfiler.RData", sep = ""))