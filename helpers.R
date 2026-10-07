library(shiny)
library(tidyverse)
# helpers functions for the Melbourne Housing Market Analysis app

# numeric variables the user can filter on
num_vars <- c(
  "Price (AUD)" = "price",
  "Distance from CBD (km)" = "distance",
  "Rooms" = "rooms",
  "Bathrooms" = "bathroom",
  "Car spaces" = "car",
  "Land size (m²)" = "landsize",
  "Building area (m²)" = "building_area",
  "Year built" = "year_built"
)


# two-value slider spanning the range of a chosen numeric variable
make_num_slider <- function(id, var, data) {
  if (var == "none") {
    return(NULL)
  }
  rng <- range(data[[var]], na.rm = TRUE)
  sliderInput(
    id,
    label = paste("Range of", names(num_vars)[num_vars == var]),
    min = floor(rng[1]),
    max = ceiling(rng[2]),
    value = c(floor(rng[1]), ceiling(rng[2]))
  )
}

# keep rows above of ar fall within the range or skip if no variable is chosen
filter_num_range <- function(data, var, range) {
  if (var == "none" || is.null(range)) {
    return(data)
  }
  data |>
    filter(between(.data[[var]], range[1], range[2]))
}
