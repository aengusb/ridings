library(tidyverse)
library(rgeos)
library(spdep)
library(expp)
library(rgdal)

ridings = readOGR("lfed000a16a_e/lfed000a16a_e.shp")

neighbours = poly2nb(ridings, row.names = ridings$FEDUID, queen = TRUE) %>%
  neighborsDataFrame() %>%
  merge(., ridings@data, by.x = "id", by.y = "FEDUID") %>%
  select(riding = id,
         riding_name = FEDNAME,
         riding_province = PRUID,
         id_neigh) %>%
  merge(., ridings@data, by.x = "id_neigh", by.y = "FEDUID") %>%
  select(riding, riding_name, riding_province,
         neighbour = id_neigh, neighbour_name = FEDNAME, neighbour_province = PRUID)
