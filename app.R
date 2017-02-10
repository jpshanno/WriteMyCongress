library(dplyr)
library(knitr)
library(jsonlite)
library(lubridate)
library(nominatim)
library(readr)
library(rmarkdown)
library(shiny)
library(shinyjs)
library(shinythemes)
library(tidyr)

source("functions.R")

# 
# addresses <- 
#   read.csv("Congressional_Addresses.csv", 
#            stringsAsFactors = F)
# 
# addresses$fullAddress <- 
#   paste(addresses$street,
#         addresses$city, 
#         addresses$state, sep = ", ")
# 
# addresses$office <- 
#   ifelse(addresses$city == "Washington", 
#          "D.C.", 
#          "District")
# 
# addresses$officeList <- 
#   paste(addresses$title, 
#         addresses$lastName, 
#         "-", 
#         addresses$office, sep = " ")
# 
# addresses$shortName <- 
#   paste(addresses$title, addresses$lastName, sep = " ")

# Define UI for application that draws a histogram
ui <- navbarPage(
  
   
   # Application title
  header = 
    tags$head(
      tags$style(
        HTML(
          "body{
            width:100%;
            max-width:950px;
            margin-left:auto;
            margin-right:auto;
            background-color: #ffffff;
            box-shadow: 0 0 10px;
            height:100%;
            padding-bottom: 5%;
            padding-top: 70px;
          }
          .navbar{
            margin-left:auto;
            margin-right:auto;
            width:100%;
            max-width:960px;
            box-shadow: 0 2px 5px;
          }
          @media (min-width:960px){
            html{
              background-image: linear-gradient(135deg,rgba(240,240,240,0.3), rgba(240,240,240,0.35));
            }
          }
          "
        )
      ),
      tags$script(
        "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
        
        ga('create', 'UA-86491836-2', 'auto');
        ga('send', 'pageview');
        
        "
      )
    ),
  
  windowTitle = "Write to your Members of Congress",
  title = "Write My Congress",
  theme = shinytheme("flatly"),
  position = "fixed-top",
   footer = 
     fluidRow(
       column(width = 12,
              align = "center",
              style = "font-size:9pt",
              HTML("<br><br>This project is free and open source under GNU APGLv3.<br>Source code can be found <a href = 'https://github.com/streamlinedeco/WriteMyCongress'>here</a>.<br>For more information please contact <a href = mailto:WriteMyCongress@outlook.com>WriteMyCongress@outlook.com</a><br>Congressional data from <a href = https://github.com/unitedstates>@unitedstates</a> & <a href = https://github.com/TheWalkers/congress-legislators>@TheWakers</a>.<br>The closest district office to your address is found using the <a href = http://www.phoneyourrep.com/>phoneyourrep.com</a> <a href = https://github.com/msimonborg/phone-your-rep-api>API</a>.<br>Geocoding uses the MapQuest Open Streets Mapping API.")
       )
     ),
   collapsible = TRUE,
   # Sidebar with a slider input for number of bins 
   tabPanel("Write",
            style = "width:80%; margin-right:auto; margin-left:auto", 
            useShinyjs(),
            # verbatimTextOutput("debug"),
            h2("Who are you?"),
            p("All fields are required. (No data is stored.)"),
            fluidRow(style = "margin-right:auto; margin-left:auto",
              column(width = 6,
                     textInput("conName",
                               "Your Name:",
                               width = '100%'),
                     textInput("conPhone",
                               "Phone:",
                               width = '100%'),
                     textInput("conStreet",
                               "Street:",
                               width = '100%')),
              column(width = 6,
                     textInput("conCity",
                               "City:",
                               width = '100%'),
                     textInput("conState",
                               "State:",
                               width = '100%'),
                     textInput("conZip",
                               "Zip:",
                               width = '100%')
              )
            ),
            fluidRow(
              h2("What do you want to say?"),
              column(width = 12,
                     textAreaInput2("letterBody",
                                    label = "",
                                    placeholder = "Type your message here (salutation & signature will be added):",
                                    width = '100%')
              )
            ),
            # uiOutput("officesBox"),
            fluidRow(
              h2("Where do you want to send your letters?"),
              column(width = 12,
                     align = "center",
                     selectizeInput("offices",
                                    label = "",
                                    choices =  list("Select your memebers of Congress" = ""),
                                    multiple = TRUE,
                                    width = '60%')
              )
            ),
            fluidRow(
              align = "center",
              disabled(downloadButton("downloadLetters",
                                      "Get My Letters"))
            )
   ),
   # tabPanel("Map the Offices",
   #          p("Coming soon.")),
   tabPanel("About",
            style = "width:80%; margin-right:auto; margin-left:auto", 
            h2("Thank you for being an active citizen!"),
            br(),
            p("This site was created to make it easier for anyone,",
span("regardless of ideology or affiliation, ", style = 'font-style: italic'), "to write letters to their members of Congress (MoC). There shouldn't be any need to worry about formatting the letter, finding addresses, changing the address and printing the same letter 3 times. Instead, just type your message, choose where you want to send your letter and a PDF is generated that contains a formatted letter addressed to each chosen MoC.")))
   
# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # output$debug <- renderPrint({addresses})
  
  addresses <- reactive({
    if(input$conStreet != "" &&
       input$conCity != "" &&
       input$conState != "" &&
       input$conZip != ""){
      fetch_MoC(input$conStreet,
                input$conCity,
                input$conState,
                input$conZip)}
    })
  
  
  observe({
    toggleState(id = "downloadLetters", 
           input$conName != "" &&
             input$conPhone != "" &&
             input$conStreet != "" &&
             input$conCity != "" &&
             input$conState != "" &&
             input$conZip != "" &&
             input$letterBody != "" &&
             input$offices != ""
           )
  })
  
  observe({
      updateSelectizeInput(session,
                           "offices",
                           choices = c("Select your memebers of Congress" = "",
                                       addresses()$officeList))
    })

  output$downloadLetters <- 
    downloadHandler(
      filename = "WriteMyCongress.pdf",
      content = function(file){
        
        # oldWD <- getwd()
        # setwd(tempdir())
        # on.exit(setwd(oldWD))
        
        ADDRESSES <- as.data.frame(addresses())
        
        tempLetters <- file.path(tempdir(), "Form_Letter.Rmd")
        file.copy("Form_Letter.Rmd", tempLetters, overwrite = T)
        
        reps <- input$offices
        nLetters <- length(reps)
        letters <- character(nLetters)
        for(I in 1:nLetters){
          repInfo <- ADDRESSES[ADDRESSES$officeList == reps[I],]
          repShortNames <- unique(ADDRESSES[ADDRESSES$officeList %in% input$offices, "shortName"])
          repInfo$cc <- paste(repShortNames[repShortNames != repInfo$shortName],
                              collapse = "; ")
          letters[I] <-
            readr::read_file(
              rmarkdown::render("Form_Letter.Rmd",
                                output_format = "md_document",
                                params = list(
                                  letterBody = input$letterBody,
                                  constituentName = input$conName,
                                  constituentStreet = input$conStreet,
                                  constituentCity = input$conCity,
                                  constituentState = input$conState,
                                  constituentZip = input$conZip,
                                  constituentPhone = input$conPhone,
                                  repTitle = repInfo$title,
                                  repFirstName = repInfo$firstName,
                                  repLastName = repInfo$lastName,
                                  repStreet = repInfo$street,
                                  repCity = repInfo$city,
                                  repState = repInfo$state,
                                  repZip = repInfo$zip,
                                  repCC = repInfo$cc,
                                  repPhone = repInfo$phone
                                ),
                                envir = new.env(parent = globalenv())
              )
            )
          
        }
        
        holding <- tempfile(tmpdir = getwd())
        
        write_file(knit(text = paste("\\pagenumbering{gobble}",
                                     letters,
                                     collapse = "\\newpage ")),
                   path = holding)
        rmarkdown::render(input = holding, 
               output_format = "pdf_document", 
               output_file = "pdfOut.pdf")
        file.remove(holding)
        file.rename("pdfOut.pdf", file)
        # setwd(oldWD)
      }
    ) 
}

# Run the application 
shinyApp(ui = ui, server = server)

