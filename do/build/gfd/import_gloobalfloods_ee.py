#------------------------------------------------------------------------------

# Shocks LatAm
# Julian Arteaga

#------------------------------------------------------------------------------

# Compute GFD database - Number of images for Colombia

# -----------------------------------------------
# %%

import os, sys, pathlib
import geopandas as gpd
import pandas as pd
import numpy as np
import geemap
import ee
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.dates as mdates
from datetime import date, datetime, timezone

# %% 

# Authenticate and initialize Earth Engine
ee.Authenticate()  # Prompts you to sign in to your Google Account
ee.Initialize(project='ee-jgarteaga')

sys.path.append(os.getcwd())

# Data paths:
projdir=r"/Users/julian/Documents/GitHub/shocks_latam/"
projdta=(r"/Users/julian/Library/CloudStorage/"
		  "OneDrive-Inter-AmericanDevelopmentBankGroup/shocks_latam/dta")

# %%

# GFD image collection:
gfd = ee.ImageCollection('GLOBAL_FLOOD_DB/MODIS_EVENTS/V1')

# %% 

cc_lists = gfd.aggregate_array('cc').getInfo() # 913 rows

dfo_country_list = gfd.aggregate_array('dfo_country').getInfo() # 913 rows

# %%

# Check out some images:

first_image = gfd.first()

n = 541
nth_image = ee.Image(gfd.toList(gfd.size()).get(n))

#%%

# Image date:

timestamp = nth_image.get('system:time_start').getInfo()
import datetime
date = datetime.datetime.fromtimestamp(timestamp / 1000)
print('Image date:', date.strftime('%Y-%m-%d'))

#%%

# Check image 'flooded' band:

flooded_band = nth_image.select('flooded')

floodedpix = flooded_band.reduceRegion(
    reducer=ee.Reducer.sum(),
    geometry=nth_image.geometry(),  
    scale=250,                        
    maxPixels=1e9
).get('flooded')  # get the name of the band 

allpix = flooded_band.reduceRegion(
    reducer=ee.Reducer.count(),
    geometry=nth_image.geometry(),  
    scale=250,                        
    maxPixels=1e9
).get('flooded')  # get the name of the band

# %%

# Select only images with data for Colombia: 

cc_filter = ee.Filter.stringContains('cc', 'COL')
countries_filter = ee.Filter.stringContains('countries', 'Colombia')

combined_filter = ee.Filter.Or(cc_filter, countries_filter)

colombia_images = gfd.filter(combined_filter)

# %%

# Get list of timestamps (in milliseconds since epoch)
timestamps = colombia_images.aggregate_array('system:time_start').getInfo()

# Convert to list of YYYY-MM-DD strings
dates = [datetime.datetime.fromtimestamp(ts / 1000).strftime('%Y-%m-%d') for ts in timestamps]

# Print result
print('Dates of flood events involving Colombia:')
print(dates)

# %%

# Download a single image to see how it looks like overlayed to col shpfile

# Select one image (e.g., the first)
test_image = ee.Image(colombia_images.toList(colombia_images.size()).
					  get(2)).select('flooded')

# Optionally clip to bounding box:
barranquilla_bbox = ee.Geometry.Rectangle([
    -74.90, 10.85,  # lower-left corner (lon, lat)
    -74.70, 11.10   # upper-right corner (lon, lat)
])
test_image = test_image.clip(barranquilla_bbox)

# %%

# Export the image to your Google Drive
file_name = 'flooded_bquilla'
geemap.ee_export_image_to_drive(
    ee_object=test_image,
    description='flooded_barranquilla',
    folder='earthengine',
    fileNamePrefix='flooded_barranquilla',
    region=barranquilla_bbox,
    scale=250,
    crs='EPSG:4326',
    file_per_band=False
)



# %%
task.start()
# %%
