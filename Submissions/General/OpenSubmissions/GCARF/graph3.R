library(tidyverse)
library(readr)
library(hrbrthemes)
######
options(scipen = 999)

finance <- read.csv("finance_tot.csv") %>%
  rowwise() %>%
  mutate(total_usd = sum(total_usd, usd_div, na.rm = T)) %>%
  select(-usd_div)
emdat <- read_csv("emdat_final.csv")
country_data <- read_csv("country_data.csv")

emdat_final <- read_csv("emdat_final.csv", 
                        col_select = c(iso, yr, d_type,
                                       `Lives Lost`, `Humans Affected`, 
                                       `Economic Damages (USD)`, 
                                       `Lives Lost per 100,000 people`,
                                       `Humans Affected per 100,000 people`,
                                       `Economic Damages (CPI adj; USD)`), 
                        col_types = cols(
                          iso = "c",
                          yr = "n",
                          d_type = "c",
                          `Lives Lost` = "n",
                          `Humans Affected` = "n",
                          `Economic Damages` = "n",
                          `Lives Lost per 100,000 people` = "n",
                          `Humans Affected per 100,000 people` = "n",
                          `Economic Damages (CPI)` = "n"
                        ))

emdat_final$iso <- gsub("AZO", "PRT", emdat_final$iso) # azores in portugal
emdat_final$iso <- gsub("DDR", "GER", emdat_final$iso)
emdat_final$iso <- gsub("DFR", "GER", emdat_final$iso)
# emdat_final$iso <- gsub("SCG", "Serbia and Montenegro", emdat_final$iso)
emdat_final$iso <- gsub("SPI", "ESP", emdat_final$iso)
# emdat_final$iso <- gsub("SCG", "Serbia and Montenegro", emdat_final$iso) # same as YUG 
# ### - manually converted to SRB, MNE
emdat_final$iso <- gsub("SUN", "RUS", emdat_final$iso)
emdat_final$iso <- gsub("YMN", "YEM", emdat_final$iso) # unified into Yemen
emdat_final$iso <- gsub("YMD", "YEM", emdat_final$iso) # unified into Yemen

emdat_final <- emdat_final %>%
  mutate(ctry = iso) %>%
  mutate(ctry = countrycode::countrycode(ctry, origin = "iso3c",
                                         destination = "country.name"))
## country sub regions
wb_region_list <- unique(country_data$wb_region)

LAC <- unname(unlist(country_data |> 
  select(-income_group) |>
  filter(wb_region == wb_region_list[1]) |>
  select(1)
  )
)

SA <- unname(unlist(country_data |> 
                      select(-income_group) |>
                      filter(wb_region == wb_region_list[2]) |>
                      select(1)
)
)

SSA <- unname(unlist(country_data |> 
                       select(-income_group) |>
                       filter(wb_region == wb_region_list[3]) |>
                       select(1)
)
)

ECA <- unname(unlist(country_data |> 
                       select(-income_group) |>
                       filter(wb_region == wb_region_list[4]) |>
                       select(1)
)
)

MENA <- unname(unlist(country_data |> 
                        select(-income_group) |>
                        filter(wb_region == wb_region_list[5]) |>
                        select(1)
)
)

EAP <- unname(unlist(country_data |> 
                       select(-income_group) |>
                       filter(wb_region == wb_region_list[6]) |>
                       select(1)
)
)

NorthA <- unname(unlist(country_data |> 
                          select(-income_group) |>
                          filter(wb_region == wb_region_list[7]) |>
                          select(1)
)
)

Global <-unname(unlist(country_data |> 
                         select(-income_group) |>
                         select(1)
)
)




######
#input metric (character value)
metric <- "Lives Lost"

#input country (character vector)
country <- "CHN"

#input disaster (character vector)
disaster <- c("Drought", "Flood", "Storm")

data_emdat <- emdat_final %>%
  filter(d_type %in% disaster, 
         yr <= 2020, 
         yr >= 1980, 
         iso %in% country) %>%
  select(yr, all_of(metric)) %>%
  group_by(yr) %>%
  summarize_at(vars(all_of(metric)), sum, na.rm = T)

data_fin <- finance %>%
  filter(year <= 2020, 
         year >= 1980, 
         iso %in% country) %>%
  group_by(year) %>%
  summarize(tot_finance = sum(total_usd, na.rm = T))

year <- tibble(year = seq(min(data_fin$year), max(data_fin$year), 1))

data_finance <- left_join(year, data_fin)%>%
  replace(is.na(.), 0)


#scaling second graph (finance)
f_max  <- max(data_emdat%>%select(all_of(metric)))   
s_max <- max(data_finance$tot_finance) 
f_min  <- min(data_emdat%>%select(all_of(metric)))   
s_min <- min(data_finance$tot_finance)

scale = (s_max - s_min)/(f_max - f_min)
shift = f_min - s_min

# scale secondary axis
axis <- function(x, scale, shift){
  return ((x)*scale - shift)
}

# scale secondary variable values
values <- function(x, scale, shift){
  return ((x + shift)/scale)
}

# graph
graph <- ggplot(data = data_emdat, aes(x = yr, y = .data[[metric]], color = metric)) + 
  # first graph (emdat)
  geom_line() + 
  geom_point() +
  # second graph (finance)
  geom_line(data = data_finance, aes(x = year, y = values(tot_finance, scale, shift), color = "Finance (USD)")) +
  geom_point(data = data_finance, aes(x = year, y = values(tot_finance, scale, shift), color = "Finance (USD)")) +
  scale_y_continuous(
    # label of first y axis
    name = metric, 
    # limit of first y axis
    # limits = c(f_min, f_max), 
    # first axis to scientific notation
    labels = function(x)format(x, scientific = T), 
    # second y axis
    sec.axis = sec_axis(
      # use axis function to scale axis
      ~axis(., scale, shift),
      # name of second axis
      name = "Finance (USD)", 
      # second axis to scientific notation
      labels = function(x)format(x, scientific = T)) 
  ) +
  labs(title = paste0("Relationship between ",metric, " and Finance"), 
       x = "Year",
       subtitle = "China") + 
  theme_ipsum() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank()
  )

graph
