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

# categorical variables available for tables, fills and facets
cat_vars <- c(
  "Property type" = "type",
  "Sale method" = "method",
  "Region group" = "region_group",
  "Region" = "region",
  "Sale year" = "sale_year"
)

# readable label for any variable name
var_label <- function(var) {
  all_vars <- c(num_vars, cat_vars)
  names(all_vars)[all_vars == var]
}

# one-way table (with percents) or two-way table (wide format)
make_cat_table <- function(data, var1, var2) {
  if (var2 == "none") {
    data |>
      group_by(across(all_of(var1))) |>
      summarize(count = n(), .groups = "drop") |>
      mutate(percent = round(100 * count / sum(count), 1))
  } else {
    data |>
      group_by(across(all_of(c(var1, var2)))) |>
      summarize(count = n(), .groups = "drop") |>
      pivot_wider(
        names_from = all_of(var2),
        values_from = count,
        values_fill = 0
      )
  }
}

# bar chart of var1, optionally filled by var2 and faceted
make_cat_plot <- function(data, var1, var2, facet, position) {
  p <- ggplot(data, aes(x = .data[[var1]]))

  if (var2 == "none") {
    p <- p + geom_bar(fill = "steelblue")
  } else {
    p <- p +
      geom_bar(aes(fill = .data[[var2]]), position = position) +
      labs(fill = var_label(var2))
  }

  if (facet != "none") {
    p <- p + facet_wrap(vars(.data[[facet]]))
  }

  p +
    labs(
      title = paste("Number of Sales by", var_label(var1)),
      x = var_label(var1),
      y = if (position == "fill") "Proportion of sales" else "Number of sales"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, hjust = 1))
}

# summary statistics of a numeric variable, optionally by a categorical one
make_num_summary <- function(data, num, group) {
  data <- data |> filter(!is.na(.data[[num]]))
  if (group != "none") {
    data <- data |> group_by(across(all_of(group)))
  }
  data |>
    summarize(
      n = n(),
      mean = mean(.data[[num]]),
      median = median(.data[[num]]),
      sd = sd(.data[[num]]),
      min = min(.data[[num]]),
      max = max(.data[[num]]),
      .groups = "drop"
    )
}

# histogram, box plot or scatter plot of a numeric variable
make_num_plot <- function(data, plot_type, num, scatter_x, group, facet) {
  data <- data |> filter(!is.na(.data[[num]]))

  if (plot_type == "hist") {
    p <- ggplot(data, aes(x = .data[[num]]))
    p <- if (group == "none") {
      p + geom_histogram(bins = 40, fill = "steelblue")
    } else {
      p +
        geom_histogram(
          aes(fill = .data[[group]]),
          bins = 40,
          alpha = 0.6,
          position = "identity"
        )
    }
    p <- p +
      labs(
        title = paste("Distribution of", var_label(num)),
        x = var_label(num),
        y = "Number of sales"
      )
  } else if (plot_type == "box") {
    p <- if (group == "none") {
      ggplot(data, aes(x = "All sales", y = .data[[num]])) +
        geom_boxplot(fill = "steelblue")
    } else {
      ggplot(
        data,
        aes(x = .data[[group]], y = .data[[num]], fill = .data[[group]])
      ) +
        geom_boxplot(show.legend = FALSE)
    }
    p <- p +
      labs(
        title = paste(
          var_label(num),
          "by",
          if (group == "none") "all sales" else var_label(group)
        ),
        x = if (group == "none") NULL else var_label(group),
        y = var_label(num)
      )
  } else {
    data <- data |> filter(!is.na(.data[[scatter_x]]))
    p <- ggplot(data, aes(x = .data[[scatter_x]], y = .data[[num]]))
    p <- if (group == "none") {
      p + geom_point(alpha = 0.3, color = "steelblue")
    } else {
      p + geom_point(aes(color = .data[[group]]), alpha = 0.3)
    }
    p <- p +
      labs(
        title = paste(var_label(num), "vs.", var_label(scatter_x)),
        x = var_label(scatter_x),
        y = var_label(num)
      )
  }

  if (group != "none") {
    p <- p + labs(fill = var_label(group), color = var_label(group))
  }
  if (facet != "none") {
    p <- p + facet_wrap(vars(.data[[facet]]))
  }

  p + theme_minimal()
}
