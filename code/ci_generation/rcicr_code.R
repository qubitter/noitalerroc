# ----------
# rcicr code
# ----------

# Load reverse correlation package ("rcicr")
library(rcicr)

# Base image name used during stimulus generation
# NOTE: retrieve base image name from 
baseimage <- 'im'

# File containing the contrast parameters (this file was created during stimulus generation)
rdata <- 'rcic_seed_1_time_Jul_22_2019_11_54.Rdata'

# Load response data
# NOTE: 'response_Linda19R.csv' is used for one subject code; use appropriate names for each subject
responsedata <- read.csv('response_Linda19R_unbiased.csv')

# Labels based on how data was stored in CSV files
stimulus <- responsedata$Image
response <- responsedata$Noise

# Batch generate classification images by trait
# To generate anti-noise CI, set antiCI = T
# To generate a z-map, set zmap = T
ci <- generateCI(stimulus, response, baseimage, rdata, antiCI = F, zmap = F)

# infoVal calculation
# infoVal <- computeInfoVal2IFC(ci, rdata, iter = 5)
