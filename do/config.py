import os

# Always get the project root dynamically

#%%
projdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

#%%

# Relative path to dataset
DATA_DIR = os.path.join(projdir, 'dta')

#%%
# Example file path
csv_path = os.path.join(DATA_DIR, '/src/ELCO_2019/')
# %%
