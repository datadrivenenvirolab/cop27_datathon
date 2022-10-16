library(shiny)
library(tidyverse)
library(plotly)
library(magrittr)
library(hrbrthemes)

options(scipen = 999)
# options(scipen = 0) # to enable scientific notation like e+05

## loading data
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

country_names_list <- data.frame(emdat_final$ctry) %>%
  filter(is.na(`emdat_final.ctry`) == F) %>%
  unique() %>%
  unlist() %>%
  as.vector()

# for(i in 1:nrow(emdat_final)){
#   if(emdat_final[i, 1] == "SRB"){emdat_final[i, 5] = "Serbia"}
#   else if(emdat_final[i, 1] == "MNE"){emdat_final[i, 5] = "Montenegro"}
#   else if(emdat_final[i, 1] == "CZK"){emdat_final[i, 5] = "Czech Republic"}
#   else if(emdat_final[i, 1] == "SVK"){emdat_final[i, 5] = "Slovakia"}
#   #else if(emdat_final[i, 1] == "NTH"){emdat_final[i, 5] = "Netherlands"}
#   #else if(emdat_final[i, 1] == "PRT"){emdat_final[i, 5] = "Portugal"}
#   else if(emdat_final[i, 1] == "GER"){emdat_final[i, 5] = "Germany"}
#   else if(emdat_final[i, 1] == "RUS"){emdat_final[i, 5] = "Russia"}
#   else if(emdat_final[i, 1] == "YEM"){emdat_final[i, 5] = "Yemen"}
#   else if(emdat_final[i, 1] == "ESP"){emdat_final[i, 5] = "Spain"}
# }

finance_tot <- read_csv("finance_tot.csv") %>%
  select(-X)

country_data <- read_csv("country_data.csv")

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

for_label_function <- function(x)format(x, scientific = T)


## server
shinyServer(function(input, output, session){
  
  # about description
  output$about_output <- renderText(paste("Funding for adaptation to climate change 
                                          has been severely inadequate for decades. 
                                          Countries that are the least responsible 
                                          for the current climate crisis have less 
                                          ability to adapt to the warming planet
                                          but are not given commensurate support.
                                          Using the UNFCCC Climate Finance for Climate
                                          Change Adaptation and Resilience Funding and 
                                          the EMDAT datasets, we illustate a series of
                                          data visualizations that aim to address:..."))
  
  #bringing in input values
  metric <- reactive({c(input$metric_input)})
  disaster <- reactive({(input$disaster_input)})
  start_year <- reactive({input$start_year_input})
  end_year <- reactive({input$end_year_input})
  
  metric_df <- emdat_final 
  
  metric_df_2 <- reactive({metric_df %>%
      rename(newvar = input$metric_input) %>%
      filter(d_type %in% input$disaster_input,
             yr <= input$end_year_input,
             yr >= input$start_year_input) %>% ## filter for years and disaster
      select(iso, ctry, yr, d_type, newvar) %>% ## select column for metric
              mutate(iso = as.factor(iso),
                      ctry = as.factor(ctry)) %>%
              dplyr::group_by(ctry, iso) %>% ## grouping works from glimpse output
              select(-yr, -d_type) %>%
      dplyr::summarise(metric = sum(newvar, na.rm=T)) %>%
      mutate(metric = round(metric, 0))
    })
  
  ### for testing
  # metric_df_2 <- metric_df %>%
  #   rename(newvar = "Lives Lost") %>%
  #   filter(d_type == "Flood",
  #          yr <= 2020,
  #          yr >= 1980) %>% ## filter for years and disaster
  #   select(iso, ctry, yr, d_type, newvar) %>% ## select column for metric
  #   mutate(iso = as.factor(iso),
  #          ctry = as.factor(ctry)) %>%
  #   dplyr::group_by(ctry, iso) %>% ## grouping works from glimpse output
  #   select(-yr, -d_type) %>%
  #   dplyr::summarise(metric = sum(newvar, na.rm=T)) %>%
  #   mutate(metric = round(metric, 0))
  
  m <- list(
    l = 0.5,
    r = 0.5,
    b = 0,
    t = 0,
    pad = 3
  )
  
  g <- list(
    lonaxis = list(showgrid = T),
    lataxis = list(showgrid = T),
    showland = TRUE,
    landcolor = toRGB("#e5ecf6"),
    fitbounds = "locations"
  )
    
    #### second global data graph
    #### merging finance and emdat_final first
    
    finance_df <- finance_tot

    finance_df_2 <- reactive({
      finance_df %>%
        filter(year >= input$start_year_input,
               year <= input$end_year_input) %>%
        dplyr::mutate(ctry = iso)  %>%
        dplyr::mutate(ctry = countrycode::countrycode(ctry, origin = "iso3c",
                                               destination = "country.name")) %>%
        dplyr::mutate(total_usd = coalesce(total_usd, usd_div)) %>%
        select(ctry, iso, total_usd) %>%
        group_by(ctry, iso) %>%
        summarize(sum = sum(total_usd, na.rm = T)) %>%
        ungroup()})

        g2_df <- reactive({metric_df_2() %>%
          inner_join(finance_df_2()) %>%
          mutate(cont = countrycode::countrycode(iso, origin = "iso3c",
                                                 destination = "continent"))})

        g2_xlab <- reactive({paste(input$metric_input, "from", input$start_year_input,
                                   "to",
                                   input$end_year_input,
                         sep = " ")})
        
        ### graph 1
        
        g1_title <- reactive({paste(input$metric_input, "from", input$start_year_input,
                                    "to", input$end_year_input, sep = " ")})
        g1_subtitle <- reactive({paste("Cause(s):",
                                       noquote(as.character(list(disaster()))),
                                       sep = " ")})
        
        mrg <- list(l = 15, r = 15,
                    b = 15, t = 20,
                    pad = 10)
        
        mrg2 <- list(l =15, r = 15, 
                     b= 15, t = 35, 
                     pad = 40)
        
        g1_title_font_list <- list(size = 17)
        legend_title_font_list <- list(size = 10)
        
        g1 <- reactive({plot_geo(data = metric_df_2(), 
                                 locationmode = "ISO-3", 
                                 reversescale = T) %>%
            add_trace(locations = ~iso, z = ~metric
                      #hovertemplate = paste0("Country:", `ctry`, "\n",
                       #                      "Metric:", `metric`, "\n",
                        #                     "<extra></extra>")
          ) %>%
            layout(geo = g, margin = mrg) %>%
            layout(title = list(text = paste0(g1_title()), 
                                font = g1_title_font_list)) %>%
            colorbar(thickness = 8, len = 0.3, title = "")})
        
        p <- reactive({(ggplot(data = g2_df(), aes(x=(metric),
                                         y = (sum/(1000000)),
                                         #label = ctry,
                                         col = cont)) +
                geom_point(alpha = 0.6,
                           aes(text = paste0("Country: ", `ctry`, "\n",
                                             "Metric: ",  `metric`, "\n",
                                             "Funding: ", signif(sum,digits =3),
                                             sep = ""))) +
                geom_smooth(method='lm', formula= y~x,
                            col="black", se =F,
                            linetype="dashed") +
                ylab(paste("Climate Adaptation Funding (million)\n from",
                           input$start_year_input, "to", input$end_year_input, sep = " ")) +
                xlab(g2_xlab()) +
                scale_color_discrete(name = "Continent") +
                theme_classic() +
                theme(axis.text.x = element_text(size=4),
                      axis.text.y= element_text(size = 4),
                      legend.text = element_text(size = 5),
                      legend.title = element_text(size = 6),
                      axis.title.x = element_text(size=5),
                      axis.title.y=element_text(size=5)))})
        
        g2 <- reactive({(
          ggplotly(p(), tooltip = c("text")
                   #, tooltip = c("ctry", "metric", "sum")
                   )
          )})
        
        ### graph 3
        # year <- tibble(year = seq(min(finance_df$year), 
        #                           max(finance_df$year), 1))
        # 
        # metric_df_3 <- emdat_final %>%
        #   inner_join(., select(country_data, iso, country, wb_region)) %>%
        #   select(-country)
        # 
        # mdf_3 <- reactive({
        #   if(input$country_input %in% wb_region_list){
        #   tmp <- metric_df_3 %>%
        #     filter(wb_region %in% input$country_input) %>%
        #     select(iso, yr, d_type, ctry, wb_region, input$metric_input_2) %>% 
        #     rename(newvar = input$metric_input_2) %>%
        #     filter(d_type %in% input$disaster_input_2) %>%
        #     group_by(yr) %>%
        #     summarize(metric = sum(newvar, na.rm = T))
        #   tmp}
        #   else{
        #     tmp <- metric_df_3 %>%
        #       select(-wb_region) %>%
        #       filter(ctry %in% input$country_input) %>%
        #       select(iso, yr, d_type, ctry, input$metric_input_2) %>% 
        #       rename(newvar = input$metric_input_2)
        #       filter(d_type %in% input$disaster_input_2) %>%
        #       group_by(yr) %>%
        #       summarize(metric = sum(newvar, na.rm = T))
        #     tmp}
        #   })
        
        # mdf_3 <- metric_df_3 %>%
        #   filter(wb_region == "East Asia & Pacific") %>%
        #   select(iso, yr, d_type, ctry, wb_region, "Lives Lost") %>% 
        #   rename(newvar = "Lives Lost") %>%
        #   filter(d_type %in% "Flood") %>%
        #   group_by(yr) %>%
        #   summarize(metric = sum(newvar, na.rm = T))
        
        # fdf_3 <- reactive({
        #   if(input$country_input %in% wb_region_list){
        #     tmp <- finance_df %>%
        #       inner_join(., select(country_data, iso, country, wb_region)) %>%
        #       select(-Country) %>%
        #       rename(ctry = country) %>%
        #       dplyr::mutate(total_usd = coalesce(total_usd, usd_div)) %>%
        #       select(-source, -usd_div) %>%
        #       filter(wb_region == input$country_input) %>%
        #       select(-ctry, -iso) %>%
        #       group_by(year) %>%
        #       summarize("total_usd" = sum(total_usd), na.rm = T) %>%
        #       left_join(year, .) %>%
        #       mutate(total_usd = replace_na(total_usd, 0))
        #   tmp}
        #   else{
        #     tmp <- finance_df %>%
        #       rename(ctry = Country) %>%
        #       filter(ctry %in% input$country_input) %>%
        #       inner_join(., select(country_data, iso, country, wb_region)) %>%
        #       select(-country) %>%
        #       dplyr::mutate(total_usd = coalesce(total_usd, usd_div)) %>%
        #       select(-usd_div, -source) %>%
        #       group_by(year) %>%
        #       mutate(total_usd = replace_na(total_usd, 0)) %>%
        #       summarize("total_usd" = sum(total_usd), na.rm = T) %>%
        #       left_join(year, .) %>%
        #       mutate(total_usd = replace_na(total_usd, 0))
        #   tmp}
        # })
        # 
        # ####
        # 
        # g3 <- reactive({
        #   ggplot(data = mdf_3(), aes(x = yr, y = metric, 
        #                                    color = metric)) + 
        #   # first graph (emdat)
        #   geom_line() + 
        #   geom_point() +
        #   # second graph (finance)
        #   geom_line(data = fdf_3(), aes(x = yr, y = tot_sum, color = "Finance (USD)")) +
        #   geom_point(data = fdf_3(), aes(x = yr, y = tot_sum, color = "Finance (USD)")) +
        #   scale_y_continuous(
        #     # label of first y axis
        #     name = input$metric_input_2, 
        #     labels = for_label_function, 
        #     sec.axis = sec_axis(name = "Finance (USD)", 
        #       labels = for_label_function) 
        #   ) +
        #   labs(title = paste0("Relationship between ", input$metric_input_2, " and Finance"), 
        #        x = "Year") + 
        #   theme_ipsum() +
        #   theme(
        #     legend.position = "bottom", 
        #     legend.title = element_blank()
        #   )
        # })

        ## final - print graph!
        
        fig <- reactive({subplot(g1(), g2(), nrows = 2, heights = c(0.5, 0.5))})
      
        output$graph_1 <- renderPlotly({
          if(input$button>=1){isolate(print(fig()))}

  })})
