#!/usr/bin/env Rscript

library(withr)
with_path("/usr/local/ncbi/blast/bin/", Sys.getenv("PATH"), "prefix")

###################### 
# this is the old way to run it locally
shiny::runApp("/home/ubuntu/ShinyWebApp/")
