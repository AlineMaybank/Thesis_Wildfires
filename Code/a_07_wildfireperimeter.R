#a_07_wildfireperimeter

#GroundOverlay_wildfire_Perimeter

#Wildfire perimeter

#Dataset: KMZ BC Fire Points 2024
#Dataset:KML Ground Overlay file 
#Both From: https://catalogue.data.gov.bc.ca/dataset/bc-wildfire-fire-perimeters-historical

# Load required packages
library(sf)
library(tidyverse)
library(lwgeom)
install.packages("rmapshaper")
library(rmapshaper)  # for geometry simplification

#2204 Wildfire Perimeters
unzip("BC Fire Points 2024.kmz", exdir = "unzipped_kmz")
fire_perimeters_2024 <- st_read("unzipped_kmz/doc.kml")

library(leaflet)

leaflet(fire_perimeters_2024) %>%
  addTiles() %>%
  addCircleMarkers(
    radius = 3,
    color = "red",
    fillOpacity = 0.7,
    popup = ~Name  # if there’s a field named "Name" or similar
  ) %>%
  addScaleBar()

#Subset to just Kamloops Department Fires
kamloops_kelowna_fires <- fire_perimeters_2024 %>%
  filter(grepl("^K", Name))  # assuming "Name" is the fire code field

#Map of Kamloops fires
# Interactive map
leaflet(kamloops_kelowna_fires) %>%
  addTiles() %>%
  addCircleMarkers(
    radius = 4,
    color = "red",
    fillOpacity = 0.8,
    label = ~Name  # Hover label
  ) %>%
  addScaleBar(position = "bottomleft")

# Optional: export just these for Google My Maps
st_write(kamloops_kelowna_fires, "kamloops_fire_points_2024.kml", driver = "KML", delete_dsn = TRUE)

#------------------------------------------------------------
#Wildfire Perimeters
getwd()
#"/Users/alinemaybank/Desktop/thesis/Analysis"

#Just the Kamloops region (drew an AOI in the data download window)
Kamloops_fire_perimeters <- st_read("BCGW_02001F02_1744383743308_14160/PROT_HISTORICAL_FIRE_POLYS_SP/H_FIRE_PLY_polygon.shp")
names(Kamloops_fire_perimeters)
#Subset to only have 2024 fires
Kamloops_2024 <- Kamloops_fire_perimeters %>%
  filter(FIRE_YEAR == 2024)
kamloops_wgs84 <- st_transform(Kamloops_2024, crs = 4326)

#Visualize the data
leaflet(kamloops_wgs84) %>%
  addTiles() %>%
  addPolygons(
    fillColor = "orange",
    fillOpacity = 0.6,
    color = "darkred",
    weight = 1,
    label = ~FIRE_NO
  ) %>%
  addScaleBar(position = "bottomleft") %>%
  addLegend("bottomright", colors = "orange", labels = "Kamloops 2024 Fires")


#Map Kelowna and Kamloops on the wildfire perimeter map
# Coordinates
# Coordinates
city_coords <- data.frame(
  city = c("Kamloops", "Kelowna"),
  lat = c(50.6756, 49.8863),
  lon = c(-120.3394, -119.4966),
  color = c("black", "blue")
)

leaflet(kamloops_wgs84) %>%
  addTiles() %>%
  addPolygons(
    fillColor = "orange",
    fillOpacity = 0.6,
    color = "darkred",
    weight = 1,
    label = ~FIRE_NO
  ) %>%
  addMarkers(
    data = city_coords,
    lng = ~lon,
    lat = ~lat,
    popup = ~city,
    icon = ~makeIcon(
      iconUrl = "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-" %+% color %+% ".png",
      iconWidth = 25, iconHeight = 41,
      iconAnchorX = 12, iconAnchorY = 41
    )
  ) %>%
  addScaleBar(position = "bottomleft") %>%
  addLegend(
    position = "bottomright",
    colors = "orange",
    labels = "2024 Fires",
    title = "Legend"
  )
