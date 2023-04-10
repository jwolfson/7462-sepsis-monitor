
# Task 1: Setup -----------------------------------------------------------

library(tidyverse)
library(data.table) ## For the fread function
library(lubridate)

library(readr)
library(knitr) # For table output in section 4
library(purrr)

library(plotly)
library(dplyr)
library(ggplot2)

source("sepsis_monitor_functions.R")

  # Task 2 is stored in file speedread_tables.R 
# Task 3: Google Drive upload ---------------------------------------------
library(googledrive)

df <- makeSepsisDataset()

# We have to write the file to disk first, then upload it
df %>% write_csv("sepsis_data_temp.csv")

folder_url <- "https://drive.google.com/drive/folders/1pnGGhgb0V9wHHiOArN_OIcWEcRXUvTaa"

# Uploading happens here
sepsis_file <- drive_put(media = "sepsis_data_temp.csv", 
                         path = folder_url,
                         name = "sepsis_data.csv")

# Set the file permissions so anyone can download this file.
sepsis_file %>% drive_share_anyone()













 


# Task 4: ICU Status Report -----------------------------------------------

# up-to-date physio data
      ## Calling drive_deauth() prevents R from trying to authenticate via a browser
      ## This is needed to make the GitHub Action work
drive_deauth()
file_link <- "https://drive.google.com/file/d/1H7RV4btxh1oWtwFx0cCQLggv_CcqVY14/view"
      
## All data up until now
new_data <- updateData(file_link)
      
## Include only most recent data
most_recent_data <- new_data %>%
  group_by(PatientID) %>%
  filter(obsTime == max(obsTime))

time <- Sys.time()
      
sep_table <- most_recent_data %>%
  filter(SepsisLabel == 1) %>%
  select(c("PatientID",
           "HR",
           "Temp",
           "Resp"))

kable(sep_table)


patients.plot <- ggplot(new_data, 
                        aes(x = obsTime)) +
  geom_line(aes(y = HR, 
                color = "HR")) +
  geom_line(aes(y = Temp, 
                color = "Temp")) +
  geom_line(aes(y = Resp, 
                color = "Resp")) +
  scale_color_manual(values = c("HR" = "red",
                                "Temp" = "blue", 
                                "Resp" = "green")) +
  labs(x = "Time", y = "Response") +
  facet_wrap(~PatientID)

patients.plot


unique(new_data$PatientID)
# create a list of ggplot objects for each patient
plot_list <- lapply(unique(new_data$PatientID), create_plot)

# create the plotly object and add the slider
ggplotly(plot_list[[1]]) %>%
  layout(
    sliders = list(
      list(
        active = 1,
        currentvalue = list(prefix = "Patient ID: "),
        pad = list(t = 20),
        steps = lapply(1:length(plot_list), function(i) {
          list(
            label = unique(new_data$PatientID)[i],
            method = "update",
            args = list(
              list(list(ggplotly(plot_list[[i]]))),
              list(title = paste("Patient ID:", unique(new_data$PatientID)[i]))
            )
          )
        })
      )
    )
  )




# Create slider for patient selection
library(plotly)
library(shiny)

?sliderInput
slider <- sliderInput("patient_id", 
                      "Patient ID:", 
                      min = min(as.numeric(df$PatientID)), 
                      max = max(as.numeric(df$PatientID)), 
                      value = min(as.numeric(df$PatientID)), 
                      step = 1)

# Create plotly output
plot_output <- plotlyOutput("patient_plot")

# Define function to embed plotly graph in HTML file
embed_plotly <- function(plotly_object, height = "100%") {
  plotly_json <- plotly_json(plotly_object)
  htmltools::tags$div(id = "plotly-div", 
                      class = "plotly-graph-div", 
                      style = sprintf("height: %s; width: 100%%;", height),
                      htmltools::HTML(sprintf('<script type="text/javascript">Plotly.newPlot("plotly-div", %s, {}, {displaylogo: false});</script>', 
                                              plotly_json)))
}







# Filter the data to keep only the last two measurements for each patient
last2obs <- alldata %>% 
  group_by(PatientID) %>% 
  arrange(desc(obsTime) )%>%
  slice_tail(n=2)
  
  
  # Calculate the change in vitals between the last two measurements for each patient
change_table <- last2obs %>% 
  group_by(PatientID) %>% 
  summarize("Change in Heart Rate" = last(HR) - first(HR),
            "Change in Temperature" = last(Temp) - first(Temp),
            "Change in Respiration Rate" = last(Resp) - first(Resp))

# Display the resulting table
kable(change_table)

  # Task 5 is housed in my git workflow .yml


## adding a bit of text so that I can test commit and push