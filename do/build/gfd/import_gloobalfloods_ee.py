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
