library(shinythemes)
library(DT)
library(leaflet)

custom_db <- c("El_Transcriptome2014")

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
                    selectInput("db", "Databse:", choices=c(custom_db,"nr"), width="300px"),
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
              )
            )
)