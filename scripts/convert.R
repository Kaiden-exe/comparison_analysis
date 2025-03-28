#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = "ortholog_groups.tsv"
# 2nd argument = outDir

library(stringr)

OGs <- args[1]
convertedOGs = paste(args[2], "orthogroups_converted.tsv", sep="/")
rawOGs = read.delim(OGs, na.strings = "*")

# Convert to orthofinder-like output
# Remove columns orthofinder output does not have
rawOGs = rawOGs[,!names(rawOGs) %in% 
              c("group_size", "sp_in_grp", "seed_ortholog_cnt")]

# Make sure column names are just speciesID names 
colnames(rawOGs) = gsub(".fasta", "", colnames(rawOGs))

# Rename first column to 'Orthogroup'
names(rawOGs)[names(rawOGs) == "group_id"] <- "Orthogroup"

# Rename orthogroups to follow orthofinder namign convention: OG0000000
rawOGs$Orthogroup = str_pad(rawOGs$Orthogroup, 7, side = "left", pad="0")
rawOGs$Orthogroup = paste("OG", rawOGs$Orthogroup, sep="")


write.table(rawOGs, file=convertedOGs, sep = "\t", quote = F, row.names = F)
