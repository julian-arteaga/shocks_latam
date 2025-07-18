# ----------------------------------------------------------------------------*

# Shocks LatAm
# Julian Arteaga
# 2025

# ----------------------------------------------------------------------------*

# Compute distance-to-sea from municipality centroid - MEXICO

#%%

import geopandas as gpd
from shapely.geometry import Point
from shapely import union_all
from shapely import box
import pandas as pd
import matplotlib.pyplot as plt

#%% 

path =  "/Users/julian/Library/CloudStorage/Dropbox/HouseholdShocks"

# Step 1: Load municipality shapefile
municipalities = (
	gpd.read_file(path + "/dta/src/SHP/mex/mun22gw.shp")
)

municipalities = municipalities.to_crs("EPSG:6372")

# Step 2: Compute centroids
municipalities["centroid"] = municipalities.geometry.centroid
centroids = municipalities.set_geometry("centroid")

#%%

# Step 3: Load coastline shapefile
coastline = (
	gpd.read_file(path + "/dta/src/SHP/ne_10m_coastline/ne_10m_coastline.shp")
)

bbox = box(-118.5, 14.0, -86.5, 33.0)
bbox_gdf = gpd.GeoDataFrame(geometry=[bbox], crs="EPSG:4326")

# Clip coastline to bounding box BEFORE reprojection
coastline = gpd.overlay(coastline, bbox_gdf, how="intersection")

# # Now reproject safely
utm_crs = "EPSG:6372"
coastline = coastline.to_crs(utm_crs)

#%%

# Dissolve coastline into one geometry
coastline_union = coastline.geometry.unary_union

#%%

# Step 5: Calculate distance
centroids["distance_to_sea_m"] = centroids.geometry.apply(
    lambda x: x.distance(coastline_union)
)
# Optional: Convert to km
centroids["distance_to_sea_km"] = centroids["distance_to_sea_m"] / 1000

#%%

# Step 6: Export results
centroids[["CVEGEO", "CVE_ENT", "CVE_MUN", "distance_to_sea_km"]].to_csv(
	path + "/dta/cln/ENNVIH/mex_munic_sea_distances.csv", index=False
)

# -------------------------------------------------------------------