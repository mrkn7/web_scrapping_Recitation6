library(rvest)
library(stringr)
library(leaflet)
library(dplyr)
library(magrittr)

# The URL 
url <- "http://www.koeri.boun.edu.tr/scripts/lst2.asp"

webpage <- read_html(url)

#Extract content with <pre> 
pre_content <- html_node(webpage, 'pre') %>% html_text()


#Split the content by new lines
lines <- str_split(pre_content, "\n")[[1]]


lines <- lines[-(1:7)] # Remove the header lines

# an empty data frame to store the earthquake data
earthquake_data <- data.frame(
  Date = character(),
  Time = character(),
  Latitude = numeric(),
  Longitude = numeric(),
  Depth = numeric(),
  MD = character(),
  ML = character(),
  Mw = character(),
  Location = character(),
  Quality = character(),
  stringsAsFactors = FALSE 
)

# Define a function to parse each line
parse_line <- function(line) {
  # Split the line by multiple spaces
  parts <- unlist(strsplit(line, "\\s+"))
  
  # Reconstruct the 'Location' field as it may contain spaces
  location <- paste(parts[9:(length(parts)-1)], collapse = " ")
  
  # Create a list with the parsed data
  list(
    Date = parts[1],
    Time = parts[2],
    Latitude = as.numeric(parts[3]),
    Longitude = as.numeric(parts[4]),
    Depth = as.numeric(parts[5]),
    MD = parts[6],
    ML = parts[7],
    Mw = parts[8],
    Location = location,
    Quality = parts[length(parts)]
  )
}

# Loop over each line and parse it
for (line in lines) {
  # Skip empty lines
  if (!all(strsplit(line, "")[[1]] == "")) {
    earthquake_data <- rbind(earthquake_data, parse_line(line))
  }
}

# Mapping part
print(earthquake_data)

earthquake_data %<>%
  mutate(Class = ifelse(ML < 2, "Minor",
                        ifelse(ML < 3, "Light", "Moderate")))
color_vector <- colorFactor(c("Gold", "Blue", "Dark Red"),
                            domain = earthquake_data$Class)
library(leaflet)
earthquake_data <- na.omit(earthquake_data)
earthquake_data |> 
  leaflet() |> 
  addTiles() |> 
  addCircles(~Longitude, ~Latitude,
             weight = 10,
             radius = 120,
             popup = paste0(
               "<b>Date: </b>",
               earthquake_data$Date,
               "<br>",
               "<b>Place: </b>",
               earthquake_data$Location,
               "<br>",
               "<b>Depth in km: </b>",
               earthquake_data$Depth,
               "<br>",
               "<b>Magnitude: </b>",
               earthquake_data$ML),
             label = ~Location,
             color = ~color_vector(Class)) |> 
  setView(lng = median(earthquake_data$Longitude),
          lat = median(earthquake_data$Latitude),
          zoom = 6)
