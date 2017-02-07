# WriteMyCongress

This project is an R Shiny app intended to make it easier for anyone to write letters to their memebers of Congress (MOC). It utilizes a basic HTML form UX to allow anyone to enter their contact information and the content of the letter they wish to send. After choosing where to send the letter(s) a PDF is generated that contains a formated letter addressed to each choosen MOC.

## Current State
A [proof of concept app](https://streamlinedecology.shinyapps.io/WriteMyCongress/) is available for the first Congressional district of Michigan (MI-01). It is fully function and will return letters for district and D.C. offices for Representative Bergman, Senator Peters, and Senator Stabenow.

## To Do
- Migrate to Amazon AWS and register custom domain.
- Fix the CC field in the addressed letter. It is currently not dynamically generated
- Incorporate Sunlight Congress API to expand from MI-01 to national audience
- Incorporate Geolocation API (OSM, SmartyStreets, etc) to more accurately match users to MOCs
- Request access to Democracy.io API to send e-mail and generate letters at once
