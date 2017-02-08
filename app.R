library(shiny)
library(shinythemes)
library(rmarkdown)
library(readr)
library(rmarkdown)
library(knitr)
library(shinyjs)
library(lubridate)
# library(nominatim)

textAreaInput2 <- function (inputId, label, value = "", width = NULL, height = NULL, 
                            cols = NULL, rows = NULL, placeholder = NULL, resize = NULL) 
{
  value <- restoreInput(id = inputId, default = value)
  if (!is.null(resize)) {
    resize <- match.arg(resize, c("both", "none", "vertical", 
                                  "horizontal"))
  }
  style <- paste("max-width: 100%;", if (!is.null(width)) 
    paste0("width: ", validateCssUnit(width), ";"), if (!is.null(height)) 
      paste0("height: ", validateCssUnit(height), ";"), if (!is.null(resize)) 
        paste0("resize: ", resize, ";"))
  if (length(style) == 0) 
    style <- NULL
  div(class = "form-group", 
      tags$label(label, `for` = inputId), tags$textarea(id = inputId, 
                                                        class = "form-control", placeholder = placeholder, style = style, 
                                                        rows = rows, cols = cols, value))
}

addresses <- 
  read.csv("Congressional_Addresses.csv", 
           stringsAsFactors = F)

addresses$fullAddress <- 
  paste(addresses$street,
        addresses$city, 
        addresses$state, sep = ", ")

addresses$office <- 
  ifelse(addresses$city == "Washington", 
         "D.C.", 
         "District")

addresses$officeList <- 
  sort(paste(addresses$title, 
             addresses$lastName, 
             "-", 
             addresses$office, sep = " "))


# osm_search(addresses$fullAddress, key = "QyfR0Wqpyl6GB67dXEU0fk2fYNnxNmSH")

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
      )),
   windowTitle = "Write to your Members of Congress",
   title = "Write My Congress",
   theme = shinytheme("flatly"),
   footer = 
     fluidRow(
       column(width = 12,
              align = "center",
              HTML("<br><br>This project is free and open source under GNU APGLv3.<br>Source code can be found <a href = 'https://github.com/streamlinedeco/WriteMyCongress'>here</a>.<br>For more information please contact <a href = mailto:WriteMyCongress@outlook.com>WriteMyCongress@outlook.com</a>")
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
                               value = "MI",
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
            fluidRow(
              h2("Where do you want to send your letters?"),
              column(width = 12,
                     align = "center",
                     selectizeInput("offices",
                                    label = "",
                                    choices = c("Select your memebers of Congress" = "", 
                                                addresses$officeList),
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
span("regardless of ideology or affilitation, ", style = 'font-style: italic'), "to write letters to their memebers of Congress (MoC). There shouldn't be any need to worry about formatting the letter, finding addresses, changing the address and printing the same letter 3 times. Instead, just type your message, choose where you want to send your letter and a PDF is generated that contains a formated letter addressed to each choosen MoC."),
            p("As it currently stands it is a working proof of concept for Michigan's 1st Congressional District. In the near future the intention is to make it a national platform where a user's address retreives their MoCs. At that time it will be migrated to a new URL, until then it is limited to a set number of active hours per month. My goal is to have the migration complete before the app is frozen for exceeding the acitve hour limit. The transistion will invovle moving from free services to paid platforms and contributions to fund registration, hosting, and hardware will be welcome.")))
   
# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # output$debug <- renderPrint(getwd())
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
  
  
  output$downloadLetters <- 
    downloadHandler(
      filename = "WriteMyCongress.pdf",
      content = function(file){
        
        # oldWD <- getwd()
        # setwd(tempdir())
        # on.exit(setwd(oldWD))
        
        tempLetters <- file.path(tempdir(), "Form_Letter.Rmd")
        file.copy("Form_Letter.Rmd", tempLetters, overwrite = T)
        
        reps <- input$offices
        nLetters <- length(reps)
        letters <- character(nLetters)
        for(I in 1:nLetters){
          repInfo <- addresses[addresses$officeList == reps[I],]
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
                                  repCC = repInfo$cc
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
        # file.remove(holding)
        file.rename("pdfOut.pdf", file)
        # setwd(oldWD)
      }
    ) 
}

# Run the application 
shinyApp(ui = ui, server = server)

