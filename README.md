# WriteMyCongress

## Summary
This project is intended to make it easier for anyone to write letters to their memebers of Congress (MoC). It shiny and R to allow anyone to enter their contact information and the content of the letter they wish to send. After choosing where to send the letter(s) a PDF is generated that contains a formatted letter addressed to each chosen MoC.
The purpose of the project is for *anyone* to more easily send letters so sample letters on political topics will not be included.

## Data
Congressional data from [@unitedstates](https://github.com/unitedstates) and [@TheWakers](https://github.com/TheWalkers/congress-legislators). The closest district office to your address is found using the [phoneyourrep.com](http://www.phoneyourrep.com/) [API](https://github.com/msimonborg/phone-your-rep-api). Geocoding is done using the MapQuest Open Streets Mapping API.

## To Do
- Add an example letter.
- Add redirect from original shinyapps URL to writemycongress.com
- Add dialog when multiple locations are returned for geolocation
- Add postcard option
- Add Senate and House committees
