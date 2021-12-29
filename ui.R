library(shinythemes)
library(DT)
library(leaflet)
library(igraph)
library(networkD3)

#name the databaes for BLAST options
custom_db <- c("E. lineata Transcriptome 2014")
custom_db2 <- c("E. carnea Transcriptome 2018")

# render foodwebpanel rmd into html so that reference citations can be styled from bibliography in the YAML
rmarkdown::render("FoodWebPanel.Rmd", output_dir = "www")

########## set up infection frequency plotting variables #######
vars <- list("1964" = "1964",
             "1965" = "1965",
             "2004" = "2004",
             "2005" = "2005",
             "2006" = "2006",
             "2010" = "2010",
             "2011" = "2011",
             "2012" = "2012",
             "2013" = "2013")

########## Shiny UI ###################
ui <- fluidPage(theme = shinytheme("simplex"),
                tagList(
                    tags$head(
                        tags$link(rel="stylesheet", type="text/css",href="style.css"),
                        tags$script(type="text/javascript", src = "busy.js")
                    )
                ),
                
                #set up navbar
                navbarPage("EdwardsiellaBase",
                           
                #Tab panel for "About" section
                    tabPanel("About",
                        mainPanel(
                          headerPanel('Edwardsiella'),
                            includeMarkdown("About.Rmd"),
                            img(src = "Elineata_2013_WH.png", height = 500),
                          p("Colony of adult E. lineata polyps in Woods Hole, MA"),
                              )
                           ),
                           
                #new tab panel for BLAST
                    tabPanel("BLAST",
                
                #This block gives us all the inputs:
                mainPanel(
                    headerPanel('Basic Local Alignment Search Tool'),
                    textAreaInput('query', 'Enter Query Sequence:', value = "", placeholder = "", width = "600px", height="200px"),
                    selectInput("db", "Databse:", choices=c(custom_db, custom_db2), width="300px"),
                    div(style="display:inline-block",
                        selectInput("program", "Program:", choices=c("blastn","tblastn","blastx","blastp","tblastx"), width="100px")),
                    div(style="display:inline-block",
                        selectInput("eval", "e-value:", choices=c(1,0.001,1e-4,1e-5,1e-10), width="120px")),
                    actionButton("blast", "BLAST!")
                ),
                
                #this snippet generates a progress indicator for long BLASTs
                div(class = "busy",  
                    p("Calculation in progress.."), 
                    img(src="https://i.stack.imgur.com/8puiO.gif", height = 100, width = 100,align = "center")
                ),
                
                #Basic results output
                mainPanel(
                    h4("Results"),
                    DT::dataTableOutput("blastResults"),
                    p("Alignment:", tableOutput("clicked") ),
                    verbatimTextOutput("alignment")
                ),
              ),
              
              # next panel of navbar
              tabPanel("Populations",
                mainPanel(
                    headerPanel('Edwardsiella populations'),
                    mainPanel(
                      h4("Collection sites"),
                      leafletOutput("mymap", width="500px", height="500px")
                    )
                )
              ),
              
              # Download Panel title ----
              tabPanel("Resources",
                headerPanel('Download Genomic Sequences'),
                
                
                # Sidebar with a slider input for number of bins
                sidebarLayout(
                  sidebarPanel(
                    # Input: Choose dataset ----
                    selectInput("dataset", "Choose a dataset:",
                                choices = c("E. lineata Transcriptome 2014")),
                    
                    # Button
                    downloadButton("downloadData", "Download")
                    
                  ),
                  
                  # Main panel for displaying outputs ----
                  mainPanel(
                    headerPanel('Edwardsiella Genomic Resources'),
                    tableOutput("table")
                  )
                )
                ),
              
              # Infection Frequency Panel title ----
              tabPanel("Host-parasite",
                headerPanel( "Ctenophore Infection Frequency" ),
              sidebarLayout(
                sidebarPanel(
                  selectInput("year", "Select year", vars, selected = "1964", multiple = TRUE),
                ),
                mainPanel(
                  tabPanel("Plot",
                           plotOutput("plot_off")
                          )
                        )
                      )
                    ),
              
              #Tab panel for "food web" 
              tabPanel("Food Web",
                       mainPanel(
                         headerPanel('Carbon Flow Through Food Web'),
                         tabPanel("plot",
                                  visNetworkOutput("plot_network")
                         ),
                         #rmarkdown::render("FoodWebPanel.Rmd", output_dir = "www"),
                         htmltools::tags$iframe(src = "FoodWebPanel.html", width = '100%',  height = 1000,  style = "border:none;")
                       )
              )
          )
)