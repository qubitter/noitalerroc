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
# NOTE: 'response_conan19r.csv' is used for one subject code; use appropriate names for each subject; see below
responsedata <- read.csv('response_conan19r.csv')

# change code as it is warranted
stimulus <- responsedata$Image
# Use this line when generating noise CI
response <- responsedata$Noise
# Use this line when generating anti-noise CI
# response <- responsedata$Anti 

# Batch generate classification images by trait
# ci <- generateCI2IFC(stimulus, response, baseimage, rdata)
ci <- generateCI(stimulus, response, baseimage, rdata)
# ci <- generateCI(stimulus, response, baseimage, rdata, zmap = TRUE, zmapmethod = “t.test”)
# infoVal <- computeInfoVal2IFC(ci, rdata)
