#!/usr/bin/env Rscript

#set NCBI BLAST executables in the `$PATH` using withr library...this didn't work
# library(withr)
# with_path("/usr/local/ncbi/blast/bin/", Sys.getenv("PATH"), "prefix")

#set path for BLAST executables 
# old_path <- Sys.getenv("PATH")
# Sys.setenv(PATH = paste(old_path, "~/usr/local/ncbi/blast/bin/", sep = ":"))


#load RSconnect and deploy app on shinyapps.io
# library(rsconnect)
# 
# rsconnect::deployApp('~/Desktop/Edwardsiella_NGS_data/EdwardsiellaBase/')

###################### 
# this is the old way to run it locally
shiny::runApp(
  "/home/ubuntu/ShinyWebApp/")
  # port = 7088,
  # launch.browser = TRUE,
  # host = "127.0.0.1")