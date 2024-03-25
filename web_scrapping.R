#Web Scrapping
#First data life expectancy
library(rvest)
library(httr)
url_life_exp <- "https://www.worldometers.info/demographics/life-expectancy/"

res <- GET(url_life_exp)
html_con <- content(res, "text")
html_life_exp <- read_html(html_con)

life_exp <- html_life_exp |> 
  html_nodes("table") |> 
  html_table() # Extract all tables from the webpage

life_exp <- as.data.frame(life_exp)

#Second dataset
long_lat <- read.csv("https://gist.githubusercontent.com/ofou/df09a6834a8421b4f376c875194915c9/raw/355eb56e164ddc3cd1a9467c524422cb674e71a9/country-capital-lat-long-population.csv")
head(long_lat)

#Merge those two dataset with common column "Country"
all <- merge(life_exp, long_lat, by = "Country", all.x = TRUE)

#Write csv those file to mapping in Recitation 6
write.csv(all, "life_exp.csv")