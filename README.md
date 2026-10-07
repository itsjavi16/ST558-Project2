# ST558 Project 2: Melbourne Housing Explorer

Interactive Shiny app for analysis of residential property sales in Melbourne, Australia from January 2016 to March 2018.

## Purpose

The app let users filter around 27,000 property sales by property type, region, and numeric ranges (such as price or distance from the CBB), then view, download, and summarize the results. It is intended to assist in comparing sale prices and features of properties between property types and regions.

## Data
[Melbourne Housing Market dataset on Kaggle](https://www.kaggle.com/datasets/anthonypino/melbourne-housing-market), scraped from publicity available listings on Domain.com.au. Sales without price recorded were deleted and impossible values (e.g land size 0 or built year 1196) were set to missing. More descriptions on data cleaning are documented in `melbourne_housing_analysis.qmd`.

