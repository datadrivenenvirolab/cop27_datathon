library(shiny)
library(plotly)
library(tidyverse)
library(shinythemes)

emdat_final <- read_csv("emdat_final.csv", 
                        # col_select = c(iso, yr, d_type,
                        #                `Lives Lost`, `Humans Affected`, 
                        #                `Economic Damages (USD)`, 
                        #                `Lives Lost per 100,000 people`,
                        #                `Humans Affected per 100,000 people`,
                        #                `Economic Damages (CPI adj; USD)`), 
                        col_types = cols(
                          iso = "c",
                          yr = "n",
                          d_type = "c",
                          `Lives Lost` = "n",
                          `Humans Affected` = "n",
                          `Economic Damages (USD)` = "n",
                          `Lives Lost per 100,000 people` = "n",
                          `Humans Affected per 100,000 people` = "n",
                          `Economic Damages (CPI ajd; USD)` = "n"
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

country_data <- read_csv("country_data.csv")

country_names_list <- data.frame(emdat_final$ctry) %>%
  filter(is.na(`emdat_final.ctry`) == F) %>%
  unique() %>%
  unlist() %>%
  as.vector()

wb_region_list <- unique(country_data$wb_region)

`Latin America & Carribean` <- unname(unlist(country_data |> 
                                               select(-income_group) |>
                                               filter(wb_region == wb_region_list[1]) |>
                                               select(1)))

`South Asia` <- unname(unlist(country_data |> 
                                select(-income_group) |>
                                filter(wb_region == wb_region_list[2]) |>
                                select(1)))

`Sub-Saharan Africa` <- unname(unlist(country_data |> 
                                        select(-income_group) |>
                                        filter(wb_region == wb_region_list[3]) |>
                                        select(1)))

`Europe & Central Asia` <- unname(unlist(country_data |> 
                                           select(-income_group) |>
                                           filter(wb_region == wb_region_list[4]) |>
                                           select(1)))

`Middle East & North Africa` <- unname(unlist(country_data |> 
                                                select(-income_group) |>
                                                filter(wb_region == wb_region_list[5]) |>
                                                select(1)))

`East Asia & Pacific` <- unname(unlist(country_data |> 
                                         select(-income_group) |>
                                         filter(wb_region == wb_region_list[6]) |>
                                         select(1)))

`North America` <- unname(unlist(country_data |> 
                                   select(-income_group) |>
                                   filter(wb_region == wb_region_list[7]) |>
                                   select(1)))

`Global` <-unname(unlist(country_data |> 
                           select(-income_group) |>
                           select(1)))

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("superhero"),
  ui <- navbarPage(title = "Global Climate Adaptation and Resilience Finance",
                   tabPanel(title = "Application",
                    sidebarLayout(
                    sidebarPanel(width = 3,
                                 # choosing the disasters of interest
                                 h5("Adjust the options below to view the desired graph and enter to see graph."),
                                 checkboxGroupInput("disaster_input", "Select type of disaster.",
                                                    c("Flood", "Landslide", "Extreme temperature",
                                                      "Insect infestation", "Epidemic",
                                                      "Storm", "Wildfire",
                                                      "Drought", "Mass movement (dry)" #add on here
                                                    ), selected = "Flood"),
                                 br(),
                                 ## choosing metrics of interest
                                 selectInput("metric_input", "Select risk metric for map and graph.",
                                             c("Lives Lost", "Humans Affected", 
                                               "Economic Damages (USD)", 
                                               "Lives Lost per 100,000 people",
                                               "Humans Affected per 100,000 people",
                                               "Economic Damages (CPI adj; USD)" #add on here
                                             ), selected = "Lives Lost"),
                                 br(),
                                 sliderInput("start_year_input", "Select start year", 
                                             min = 1969, max = 2020, value = 2000),
                                 br(),
                                 sliderInput("end_year_input", "Select end year",
                                             min = 1969, max = 2020, value = 2010),
                                 br(),
                                 actionButton('button', label = 'Enter')
                                 
                    ),
                    mainPanel(width = 9,
                              br(),
                              br(),
                              plotlyOutput("graph_1", height = 700), 
                              br(),
                              h5("The risk metric is the horizontal axis of the graph plotted. 
                                  The vertical axis is the total funding (million USD) for climate 
                                  adaptation and resilience for selected year range. The data is taken
                                 from the Emergency Event Database (EMDAT) and United Nations Framework 
                                 Convention on Climate Change Climate Finance database, 
                                 and is accurate as of 27 September 2022."))
                              )
                    )
    )
  )
)