library(tidyverse)
library(data.table) 
library(lubridate)
library(googledrive)
library(googledrive)
source("sepsis_monitor_functions.R")

scopes <- "https://www.googleapis.com/auth/drive"
options("gargle_oauth_email" = "zhan8639@umn.edu") # Replace with your email
options("gargle_oauth_cache" = "Sepsis") # This sets a cache folder for your tokens
drive_auth(path = "Sepsis", scopes = scopes)

# Task 2
library(tictoc)
patients_list <- c(50, 100, 500)
results <- list()

for (n in patients_list) {
  
  # Time the execution of makeSepsisDataset using fread
  tic()
  dataset_fread <- makeSepsisDataset(n = n, read_fn = "fread")
  time_fread <- toc(log = TRUE)
  
  # Time the execution of makeSepsisDataset using read_delim
  tic()
  dataset_read_delim <- makeSepsisDataset(n = n, read_fn = "read_delim")
  time_read_delim <- toc(log = TRUE)
  
  # Store the results
  results[[as.character(n)]] <- list(
    fread = list(data = dataset_fread, time = time_fread),
    read_delim = list(data = dataset_read_delim, time = time_read_delim)
  )
}

for (n in names(results)) {
  cat("Results for", n, "patients:\n")
  cat("fread:      ", results[[n]]$fread$time$toc - results[[n]]$fread$time$tic, "seconds\n")
  cat("read_delim: ", results[[n]]$read_delim$time$toc - results[[n]]$read_delim$time$tic, "seconds\n")
  cat("\n")
}

# Results for 50 patients:
# fread:       9.91 seconds
# read_delim:  30.49 seconds
# 
# Results for 100 patients:
# fread:       19.05 seconds
# read_delim:  65.96 seconds
# 
# Results for 500 patients:
# fread:       98.58 seconds
# read_delim:  317.06 seconds



# Task 3

library(googledrive)

df <- makeSepsisDataset(500)

# We have to write the file to disk first, then upload it
df %>% write_csv("sepsis_data_temp.csv")

# Uploading happens here
sepsis_file <- drive_put(media = "sepsis_data_temp.csv", 
                         path = "https://drive.google.com/drive/folders/1zprNFqiORbAI8rf4yypOAmgDyon637je",
                         name = "sepsis_data.csv")

# Set the file permissions so anyone can download this file.
sepsis_file %>% drive_share_anyone()

drive_deauth()
file_link <- "https://drive.google.com/file/d/1wCfQLLZB09Ezfdd3Uth_OGXPdmUPdoKu"

new_data <- updateData(file_link)

most_recent_data <- new_data %>%
  group_by(PatientID) %>%
  filter(obsTime == max(obsTime))
