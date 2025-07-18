# ----------------------------------------------------------------------------*

# Shocks LatAm
# Julian Arteaga
# 2025

# ----------------------------------------------------------------------------*

# Map of countries with available household surveys

# ---------------------------
# Load required packages
library(sf)
library(rnaturalearth)
library(ggplot2)
library(dplyr)
library(here)

here()

# Get world countries data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Define countries of interest
group1 <- c("Colombia", "Mexico", "Peru", 
            "El Salvador", "Haiti")
group2 <- c("Ecuador", "Chile", "Dominican Rep.", "Honduras", "Guatemala")

# Create a new column indicating the group
world <- world %>%
  mutate(highlight = case_when(
    name %in% group1 ~ "Panel",
    name %in% group2 ~ "Cross Section",
    TRUE ~ NA_character_
  ))

# Filter to show only Latin America and Caribbean region
lac_countries <- world %>%
  filter(region_un == "Americas") %>%
  filter(subregion %in% c("South America", "Central America", "Caribbean"))

# Plot
g1 <- ggplot() +
  geom_sf(data = lac_countries, fill = "gray90", color = "white") +
  geom_sf(
    data = filter(world, highlight == "Panel"),
    aes(fill = highlight),
    color = "black"
  ) +
  geom_sf(
    data = filter(world, highlight == "Cross Section"),
    aes(fill = highlight),
    color = "black"
  ) +
  scale_fill_manual(
    values = c("Panel" = "steelblue", "Cross Section" = "tomato")
  ) +
  coord_sf(crs = "EPSG:3395") +
  theme_minimal() +
  theme(legend.title = element_blank(),
    	panel.grid.major = element_blank(),  # removes latitude/longitude lines
 	    panel.grid.minor = element_blank()
  )
  #+labs(title = "Household Surveys with Shock Module")

ggsave(here("out/surveys_by_country.png"), g1, dpi = 300)

# -------------------------------------------------------------------