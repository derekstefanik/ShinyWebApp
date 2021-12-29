

require(shiny)
require(XML)
library(plyr)
library(dplyr)
library(DT)
library(leaflet)
library(withr)
library(seqinr)
library(lubridate)
library(ggplot2)
library(shape)
library(scales)
library(igraph)
library(networkD3)
library(knitr)
library(visNetwork)


########## Prepare ctenophore infection frequency data #################
#read in the file
CtenoInfections <- read.csv(file = "Data/Cteno-infections_dates_longFormat.csv", stringsAsFactors = FALSE)

#transform character date format into date format
CtenoInfections$Date <- as.Date(CtenoInfections$Date)

#pull out the year from the date and create a year column for each row
CtenoInfections$year <- year(CtenoInfections$Date)

#add column for MonthDay converted from the date
CtenoInfections$MonthDay <- format(CtenoInfections$Date, "%m-%d")

#group by year and create new dataframe
CtenoMonthDay <- CtenoInfections %>% group_by(year, MonthDay)

#transform character MonthDay format into date format
CtenoMonthDay$MonthDay <- as.Date(CtenoMonthDay$MonthDay, format = "%m-%d")

################# Prepare Food Network data #############################
nodes <- read.csv("Data/EdFoodWeb_nodes.csv")
edges <- read.csv("Data/EdFoodWeb_edges.csv")
nodesdf <- data.frame(nodes)
edgesdf <- data.frame(edges)

################# Begin Server Function ##############################
server <- function(input, output, session){
    
    custom_db <- c("E. lineata Transcriptome 2014")
    custom_db_path <- c("./blast_db/EdTx")
    custom_db2 <- c("E. carnea Transcriptome 2018")
    custom_db2_path <- c("./EcarneaTranscriptome/EcarneaTx")
    Parasites <- read.csv("Data/Edwardsiella_parasite_CollectionLocationsUpdated.csv")

   
    blastresults <- eventReactive(input$blast, {
        
        #gather input and set up temp file
        query <- input$query
        tmp <- tempfile(fileext = ".fa")
        
        #if else chooses the right database
        if (input$db == custom_db){
            db <- custom_db_path
            remote <- c("")
        } else {
            (input$db == custom_db2)
            db <- custom_db2_path
            #add remote option for nr since we don't have a local copy
            remote <- c("")
        }
        
        #this makes sure the fasta is formatted properly
        if (startsWith(query, ">")){
            writeLines(query, tmp)
        } else {
            writeLines(paste0(">Query\n",query), tmp)
        }
        
        #calls the blast
        data <- system(paste0(input$program," -query ",tmp," -db ",db," -evalue ",input$eval," -outfmt 5 -max_hsps 1 -max_target_seqs 10 ",remote), intern = T)
        xmlParse(data)
    }, ignoreNULL= T)
    
    #Now to parse the results...
    parsedresults <- reactive({
        if (is.null(blastresults())){}
        else {
            xmltop = xmlRoot(blastresults())
            
            #the first chunk is for multi-fastas
            results <- xpathApply(blastresults(), '//Iteration',function(row){
                query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
                hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
                hit_length <- getNodeSet(row, 'Iteration_hits//Hit//Hit_len') %>% sapply(., xmlValue)
                bitscore <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_bit-score') %>% sapply(., xmlValue)
                eval <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_evalue') %>% sapply(., xmlValue)
                cbind(query_ID,hit_IDs,hit_length,bitscore,eval)
            })
            #this ensures that NAs get added for no hits
            results <-  rbind.fill(lapply(results,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
        }
    })
    
    #makes the datatable
    output$blastResults <- renderDataTable({
        if (is.null(blastresults())){
        } else {
            parsedresults()
        }
    }, selection="single")
    
    #this chunk gets the alignemnt information from a clicked row
    output$clicked <- renderTable({
        if(is.null(input$blastResults_rows_selected)){}
        else{
            xmltop = xmlRoot(blastresults())
            clicked = input$blastResults_rows_selected
            tableout<- data.frame(parsedresults()[clicked,])
            
            tableout <- t(tableout)
            names(tableout) <- c("")
            rownames(tableout) <- c("Query ID","Hit ID", "Length", "Bit Score", "e-value")
            colnames(tableout) <- NULL
            data.frame(tableout)
        }
    },rownames =T,colnames =F)
    
    #this chunk makes the alignments for clicked rows
    output$alignment <- renderText({
        if(is.null(input$blastResults_rows_selected)){}
        else{
            xmltop = xmlRoot(blastresults())
            
            clicked = input$blastResults_rows_selected
            
            #loop over the xml to get the alignments
            align <- xpathApply(blastresults(), '//Iteration',function(row){
                top <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_qseq') %>% sapply(., xmlValue)
                mid <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_midline') %>% sapply(., xmlValue)
                bottom <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_hseq') %>% sapply(., xmlValue)
                rbind(top,mid,bottom)
            })
            
            #split the alignments every 40 carachters to get a "wrapped look"
            alignx <- do.call("cbind", align)
            splits <- strsplit(gsub("(.{40})", "\\1,", alignx[1:3,clicked]),",")
            
            #paste them together with returns '\n' on the breaks
            split_out <- lapply(1:length(splits[[1]]),function(i){
                rbind(paste0("Q-",splits[[1]][i],"\n"),paste0("M-",splits[[2]][i],"\n"),paste0("H-",splits[[3]][i],"\n"))
            })
            unlist(split_out)
        }
    })
    
    #leaflet map
    pal <- colorFactor(c("navy", "red"), domain = unique(Parasites$LifeStage))
    
    output$mymap <- renderLeaflet({
        leaflet(data = Parasites) %>%
            addTiles() %>%
            addCircleMarkers(~longitude, 
                             ~latitude, 
                             color = ~pal(LifeStage),
                             stroke = FALSE, fillOpacity = 0.5,
                             popup  = ~paste0(Location, 
                                              "<br/>Collector: ", Collector,
                                              "<br/>Year: ", Year)) %>%
            addLegend(pal = pal, values = ~LifeStage, opacity = 1)
    })
    
    ####### DATA DOWNLOAD ################
    # Reactive value for selected dataset ----
    EdTxFasta <- read.fasta("EdTranscriptome.gz")
    #Write the Edwardsiella transcriptome sequences to a temporary file
    #fname <- tempfile(pattern = "EdFasta", tmpdir = tempdir(), fileext = "fasta")
    
    # Reactive value for selected dataset ----
    datasetInput <- reactive({
        switch(input$dataset,
               "E. lineata Transcriptome 2014" == EdTxFasta)
    })
    
    
    # Table of selected dataset ----
    # output$table <- renderTable({
    #     datasetInput()
    # })
    
    # Downloadable fasta of selected dataset ----
    output$downloadData <- downloadHandler(
        #This function returns a string which tells the client
        # browser what name to use when saving the file.
        filename = paste("EdTx","fasta", sep = "."),
        # This function should write data to a file given to it by
        # the argument 'file'.
        content = function(file) {
            # Write to a file specified by the 'file' argument
            write.fasta(sequences = EdTxFasta, names = names(datasetInput()), open = "w", nbchar = 60, file.out = file, as.string = FALSE)
        }
    )
    
    ########### Infection Frequency Panel ###########################
    observe({
        
        Cteno_df <- CtenoMonthDay[CtenoMonthDay$year %in% input$year,]
        output$plot_off <- renderPlot({
            O <-ggplot(data = Cteno_df, aes(x=MonthDay,y=Infection.Freq., color=as.factor(year))) +
                geom_point(size =3, alpha = 0.75) +
                scale_colour_hue(l=50) +
                ggtitle("Infection Frequency of Ctenophores at Woods Hole") +
                labs(x="Time",y="Infection Frequency")+
                theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32, hjust=0.5)) +
                theme(axis.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=22))+
                theme_classic()
            O
        })
        
    })
    
    # create a dataset:
    
    data <- data.frame(
        from=c("Edwardsiella", "Mnemiopsis", "Mnemiopsis"),
        to=c("Mnemiopsis", "Beroe", "Butterfish")
    )
    
    # Plot
    output$plot_network <- renderVisNetwork({
    
    visNetwork(nodesdf, edgesdf) %>% visEdges(arrows = "to") %>%
        visOptions(collapse = TRUE) %>%
        visInteraction(navigationButtons = TRUE) %>%
        visLegend(position="left", zoom=FALSE)
    })
}