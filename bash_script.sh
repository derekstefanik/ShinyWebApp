sudo apt-get -y update
sudo chown -R ubuntu /etc/apt
sudo apt-key adv -keyserver keyserver.ubuntu.com -recv-keys E084DAB9
sudo add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/'
sudo apt-get -y update
sudo apt-get install -y --force-yes r-base-core
sudo apt-get -y update
sudo chown -R ubuntu /etc/apt
sudo apt-key adv -keyserver keyserver.ubuntu.com -recv-keys E084DAB9
sudo add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/'
sudo apt-get -y update
sudo apt-get install -y --force-yes r-base-core
sudo su -\-c "R -e \"install.packages( c('tidyselect' ,'xfun' ,'remotes' ,'purrr' ,'vctrs' ,'generics' ,'testthat' ,'htmltools' ,'yaml' ,'rlang' ,'pkgbuild' ,'later' ,'pillar' ,'glue' ,'sessioninfo' ,'lifecycle' ,'htmlwidgets' ,'memoise' ,'callr' ,'fastmap' ,'httpuv' ,'ps' ,'crosstalk' ,'curl' ,'markdown' ,'fansi' ,'Rcpp' ,'xtable' ,'promises' ,'backports' ,'desc' ,'pkgload' ,'mime' ,'fs' ,'digest' ,'processx' ,'rprojroot' ,'cli' ,'tools' ,'magrittr' ,'tibble' ,'ramazon' ,'crayon' ,'pkgconfig' ,'ellipsis' ,'prettyunits' ,'assertthat' ,'rstudioapi' ,'R6' ,'compiler' ,'stats' ,'graphics' ,'grDevices' ,'utils' ,'datasets' ,'methods' ,'base' ,'withr' ,'dplyr' ,'plyr' ,'XML' ,'shiny' ,'leaflet' ,'DT' ,'shinythemes' ,'devtools' ,'usethis' ) , repos = 'http://cran.rstudio.com/', dep = TRUE)\""
echo 'R installed'
sudo apt-get install -y gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.7.904-amd64.deb
sudo gdebi --non-interactive shiny-server-1.5.7.904-amd64.deb

sudo chown -R ubuntu /srv/
rm -Rf /srv/shiny-server/index.html
rm -Rf /srv/shiny-server/sample-apps
