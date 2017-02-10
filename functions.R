
textAreaInput2 <<- function (inputId, label, value = "", width = NULL, height = NULL, cols = NULL, rows = NULL, placeholder = NULL, resize = NULL) 
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


capwords <<- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

fetch_MoC <<- function(zip = NULL, street = NULL, city = NULL, state = NULL){
  # if(!is.null(street)){if(street == " "){STREET <- NULL}}
  # if(!is.null(city)){if(city == " "){CITY <- NULL}}
  # if(!is.null(state)){if(state == " "){STATE <- NULL}}
  zip <- ifelse(is.numeric(zip), sprintf("%05d", zip), zip)
  useZip <- TRUE
  # geoCode <- FALSE
  # if(){geoCode <- TRUE}
  
  if(!is.null(street) & !is.null(city) & !is.null(state)){
    urlStreet <- gsub(" ", "+", street)
    urlCity <- gsub(" ", "+", city)
    urlState <- gsub(" ", "+", state)
    
    geocodeString <- 
      paste0(
        "http://open.mapquestapi.com/geocoding/v1/address?key=",
        source("nominatin_key")$value,
        "&street=",
        urlStreet,
        "&city=",
        urlCity,
        "&state=",
        urlState,
        "&postalCode=",
        zip,
        "&adminArea1=US&adminArea1Type=Country&maxResults=1")
    
    geocode <- fromJSON(geocodeString)[["results"]][["locations"]][[1]]$latLng
    if(nrow(geocode) != 0){useZip <- FALSE}
  }
  
  if(useZip){
    apiString <- 
      paste0("https://congress.api.sunlightfoundation.com/legislators/locate/?zip=",
             zip,
             "&fields=title,first_name,last_name,office,phone")
    myReps <- fromJSON(apiString)$results
    myReps <- 
      myReps %>% 
      rename(firstName = first_name,
             lastName = last_name,
             street = office) %>% 
      mutate(title = ifelse(title == "Rep",
                            "Representative",
                            "Senator"),
             city = "Washington",
             state = "D.C.",
             zip = ifelse(title == "Representative",
                          20515,
                          20510)) %>% 
      arrange(lastName)
    message("Looking up your address failed so the zip code you provided was used to retreive your Members of Congress. Zip codes can span multiple Congressional districts and states, please verify that your representatives are correct.")
  } else {
    apiString <- 
      paste0(
        "https://phone-your-rep.herokuapp.com/api/beta/reps?lat=",
        geocode$lat,
        "&long=",
        geocode$lng)
    apiReturn <- fromJSON(apiString)
    officeLocations <- 
      bind_rows(apiReturn[["reps"]][["office_locations"]]) %>% 
      select(bioguide_id, office_type, distance, address, suite, city, state, zip, phone) %>% 
      group_by(bioguide_id, office_type) %>% 
      filter(distance == min(distance)) %>% 
      ungroup()
    repIDs <-
      apiReturn[["reps"]][c("bioguide_id", "first", "last", "role")] %>% 
      separate(role, c("remove1", "remove2", "title")) %>% 
      select(-contains("remove"),
             title,
             first,
             last)
    myReps <- 
      left_join(officeLocations, repIDs) %>% 
      mutate(street = ifelse(is.na(suite),
                             address,
                             paste(address,
                                   suite,
                                   sep = ", ")),
             office_type = capwords(office_type),
             officeList = paste0(title,
                                 " ",
                                 last,
                                 " - ",
                                 office_type,
                                 " ",
                                 "Office"),
             shortName = paste(title,
                               last,
                               sep = " ")) %>% 
      rename(
        firstName = first,
        lastName = last) %>% 
      select(title, firstName, lastName, phone, street, city, state, zip, officeList, shortName) %>% 
      arrange(lastName, officeList)
  }
  return(myReps)
}
# fetch_MoC("50 Ferrier Dr", "Warwick", "RI", 02888)
# fetch_MoC("1496 Larpenteur Ave W", "Falcon Heights", "MN", "55113")
# fetch_MoC("1885 Tatum Ave", "Falcon Heights", "MN", "55113")
# fetch_MoC("804 W Water St", "Hancock", "MI", 49930)
