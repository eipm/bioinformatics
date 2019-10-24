
if( !require("BiocManager")) install.packages("BiocManager", repos = c("http://cran.us.r-project.org"), dependencies = T, quiet = T, Ncpus = 1 );
biocManager.status = require("BiocManager")
if( !biocManager.status ) stop("Cannot install BiocManager")
BiocManager::install("Biobase")
BiocManager::install("ggplot2")
BiocManager::install("openxlsx")
BiocManager::install("RColorBrewer")
BiocManager::install("reshape2")
BiocManager::install("Biobase")
BiocManager::install("BiocGenerics")