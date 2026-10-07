library(shiny)
library(bslib)
library(tidyverse)
library(DT)

source("helpers.R")

# cleaned data created in melbourne_housing_analysis.qmd
housing <- read_rds("data/melbourne_housing_cleaned.rds")

ui <- page_sidebar(
  title = "Melbourne Housing Explorer",

  sidebar = sidebar(
    width = 320,
    h4("Subset the data"),
    checkboxGroupInput(
      "type",
      "Property type",
      choices = levels(housing$type),
      selected = levels(housing$type)
    ),
    checkboxGroupInput(
      "region",
      "Region group",
      choices = levels(housing$region_group),
      selected = levels(housing$region_group)
    ),
    selectInput(
      "num_var1",
      "First numeric variable",
      choices = c("None" = "none", num_vars),
      selected = "price"
    ),
    uiOutput("num_slider1"),

    selectInput(
      "num_var2",
      "Second numeric variable",
      choices = c("None" = "none", num_vars),
      selected = "distance"
    ),
    uiOutput("num_slider2"),

    actionButton("subset_data", "Apply filters", class = "btn-primary"),
    br(),
    textOutput("n_rows")
  ),
  navset_tab(
    nav_panel(
      "About",
      h3("About this app"),
      p(
        "This app lets you explore residential property sales in Melbourne,",
        "Australia, from January 2016 to March 2018. You can filter the sales,",
        "view and download the data, and build tables and plots to compare",
        "prices across property types, regions and other characteristics."
      ),

      h4("The data"),
      p(
        "The data contains about 27,000 sales with a recorded price, scraped",
        "from public listings on Domain.com.au. Each sale includes the price,",
        "property type, sale method, region, distance from the CBD, number of",
        "rooms, land size, building area and year built. It is available on",
        a(
          "Kaggle",
          href = "https://www.kaggle.com/datasets/anthonypino/melbourne-housing-market",
          target = "_blank",
          .noWS = "after"
        ),
        "."
      ),

      h4("How to use the app"),
      tags$ul(
        tags$li(
          strong("Sidebar:"),
          "choose property types, regions and",
          "numeric ranges, then press the button to subset the data.",
          "The rest of the app updates only when the button is pressed."
        ),
        tags$li(
          strong("Data Download:"),
          "view the (subsetted) data in a table",
          "and save it as a CSV file."
        ),
        tags$li(
          strong("Data Exploration:"),
          "create contingency tables, numeric",
          "summaries and plots for the variables you choose."
        )
      ),

      img(src = "melbourne.jpg", style = "max-width: 100%;"),
      p(em(
        "Melbourne skyline from the Shrine of Remembrance, 2007.",
        "Photo by Brian W. Schaller via",
        a(
          "Wikimedia Commons",
          href = "https://commons.wikimedia.org/wiki/File:A156,_Melbourne,_Australia,_skyline_from_war_memorial,_2007.JPG",
          target = "_blank"
        ),
        "(CC BY-SA 3.0)."
      ))
    ),

    nav_panel("Data Download", p("Data table coming soon...")),
    nav_panel("Data Exploration", p("Summaries and plots coming soon..."))
  )
)

server <- function(input, output, session) {
  # dynamic sliders: rebuilt whenever a different numeric variable is chosen
  output$num_slider1 <- renderUI(make_num_slider(
    "num_range1",
    input$num_var1,
    housing
  ))
  output$num_slider2 <- renderUI(make_num_slider(
    "num_range2",
    input$num_var2,
    housing
  ))

  # start with the full dataonly replaced when the button is pressed
  subset_vals <- reactiveValues(data = housing)

  observeEvent(input$subset_data, {
    subset_vals$data <- housing |>
      filter(type %in% input$type, region_group %in% input$region) |>
      filter_num_range(input$num_var1, input$num_range1) |>
      filter_num_range(input$num_var2, input$num_range2)
  })

  # row count to confirm the subsetting works
  output$n_rows <- renderText({
    paste(
      "Showing",
      format(nrow(subset_vals$data), big.mark = ","),
      "of",
      format(nrow(housing), big.mark = ","),
      "sales"
    )
  })
}

shinyApp(ui, server)
