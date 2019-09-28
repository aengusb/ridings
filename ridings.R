library(tidyverse)
library(rgeos)
library(spdep)
library(expp)
library(rgdal)

`%nin%` = Negate(`%in%`)

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
         neighbour = id_neigh, neighbour_name = FEDNAME, neighbour_province = PRUID) %>%
  as_tibble()

# add in relevant quant_feature here
neighbours$quant_feature = rnorm(1776, 1000,300)

# pairs dataframe to get the results
pairs = data.frame(large_id = NA, small_id = NA, num_sequence = NA)
n_left = neighbours
i = 0

# Does not necessarily generate 338 pairs as all the neighbours may get used up leaving an area alone
while (nrow(n_left) > 0) {
  
  i = i + 1
  
  large_id = filter(n_left, quant_feature == max(quant_feature)) %>% 
    pull(riding) %>% as.character() %>% as.numeric() %>% .[1]
  
  small_id = filter(n_left, riding == large_id) %>% 
    filter(quant_feature == min(quant_feature)) %>%
    pull(neighbour) %>% as.character() %>% as.numeric() %>% .[1]
  
  pairs[i,] = c(large_id, small_id, i)
  
  x = nrow(n_left)
  n_left = filter(n_left,
                  riding %nin% c(pairs$large_id, pairs$small_id),
                  neighbour %nin% c(pairs$large_id, pairs$small_id))
  x = x - nrow(n_left)
  
  print(paste(i,":"," pairing ",large_id, " and ",small_id,". Removed ",x,"rows.", sep = ""))
  
}


