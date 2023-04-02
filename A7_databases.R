

# Task 1: Setup -----------------------------------------------------------

library(tidyverse)
library(data.table) ## For the fread function
library(lubridate)

source("sepsis_monitor_functions.R")

df <- initializePatients()

# Task 2: Google Drive upload ---------------------------------------------

library(googledrive)

## Authenticate to Drive, using a token on my local machine
drive_auth(email = "north370@umn.edu",
           path = "G:/My Drive/Sepsis/client_secret_58930731896-mvdks0g8ebitmie0kjdtmhapvicrfs6h.apps.googleusercontent.com.json")

# We have to write the file to disk first, then upload it
df %>% write_csv("sepsis_report_temp.csv")

# Uploading happens here
url <- "1pnGGhgb0V9wHHiOArN_OIcWEcRXUvTaa"

drive_put(media = "sepsis_report_temp.csv",  
          path = url, # README: getting error -- Parent specified via `path` is invalid:
          name = "sepsis_report.csv") 


# Task 3: Automating Data Updates ----------------------------------------

file_url <- "https://drive.google.com/file/d/1WLkDq3nko2SgQTCM_A7sjCl55VxwtRVP/view?usp=sharing"

