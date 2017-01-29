library(shiny)
library(shinythemes)
library(rmarkdown)
library(leaflet)
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
   windowTitle = "Write to your Members of Congress",
   title = "",
   theme = shinytheme("flatly"),
   collapsible = TRUE,
   # Sidebar with a slider input for number of bins 
   tabPanel("Write",
            style = "width:80%; margin-right:auto; margin-left:auto", 
            useShinyjs(),
            h2("Who you are"),
            p("All field are required. No data entered into this form is stored, it is used to generate the header and body of your letter only."),
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
              h2("What you want to say"),
              column(width = 12,
                     textAreaInput2("letterBody",
                                    "Your message (salutation & signature will be added):",
                                    width = '100%')
              )
            ),
            fluidRow(
              align = "center",
              selectizeInput("offices",
                             "Where do you want to send your letters?",
                             choices = addresses$officeList,
                             selected = addresses$officeList,
                             multiple = TRUE,
                             width = '60%')
            ),
            fluidRow(
              align = "center",
              disabled(downloadButton("downloadLetters",
                             "Get My Letters"))
            )
   ),
   tabPanel("Map the Offices",
            p("Coming soon.")),
   tabPanel("About",
            p("Coming soon."))
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
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
        
        oldWD <- getwd()
        setwd(tempdir())
        holding <- tempfile()
        # holding <- file.path(tempdir(), "holding")
        
        write_file(knit(text = paste("\\pagenumbering{gobble}",
                                     letters,
                                     collapse = "\\newpage ")),
                   path = holding)
        render(input = holding, 
               output_format = "pdf_document", 
               output_file = "pdfOut.pdf")
        file.rename("pdfOut.pdf", file)
        setwd(oldWD)
      }
    ) 
}

# Run the application 
shinyApp(ui = ui, server = server)

