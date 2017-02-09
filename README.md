# WriteMyCongress

This project is an R Shiny app intended to make it easier for anyone to write letters to their memebers of Congress (MoC). It utilizes a basic HTML form UX to allow anyone to enter their contact information and the content of the letter they wish to send. After choosing where to send the letter(s) a PDF is generated that contains a formatted letter addressed to each chosen MoC.

## Current State
A [proof of concept app](http://WriteMyCongress.com) is available for the first Congressional district of Michigan (MI-01). It is fully function and will return letters for district and D.C. offices for Representative Bergman, Senator Peters, and Senator Stabenow.

## To Do
- Add redirect from shinyapps URL to writemycongress.com
- Incorporate Sunlight Congress API to expand from MI-01 to national audience
- Incorporate Geolocation API (OSM, SmartyStreets, etc) to more accurately match users to MOCs
- Add postcard option
- Add Senate and House committees
- Source a full list of MoC district offices
- Enable HTTPS
- Request access to Democracy.io API to send e-mail and generate letters at once -- THEIR API IS CURRENTLY NOT AVAILABLE
