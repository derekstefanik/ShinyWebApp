#!/usr/bin/env Rscript

#set path for BLAST executables 
old_path <- Sys.getenv("PATH")
Sys.setenv(PATH = paste(old_path, "/home/ubuntu/ncbi-blast-2.10.1+/bin/", sep = ":"))

###################### 
# this is the old way to run it locally
shiny::runApp("/home/ubuntu/ShinyWebApp/")
