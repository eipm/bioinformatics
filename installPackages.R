
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos = c("http://cran.us.r-project.org"), dependencies = T, quiet = T, Ncpus = 1 );
BiocManager::install(version = "3.16")
biocManager.status = require("BiocManager")
if( !biocManager.status ) stop("Cannot install BiocManager")
BiocManager::install("Biobase")
BiocManager::install("ggplot2")
BiocManager::install("openxlsx")
BiocManager::install("RColorBrewer")
BiocManager::install("reshape2")
BiocManager::install("Biobase")
BiocManager::install("BiocGenerics")