getPatient <- function(idnum, read_function = "fread") {
  if(is.integer(idnum)) {
    ptid_string <- sprintf("%06d", idnum)
  } else {
    ptid_string <- idnum
  }
  file_name <- sprintf("p%s.psv", ptid_string)
  url <- paste0("https://physionet.org/files/challenge-2019/1.0.0/training/training_setA/", file_name)
  
  if(read_function == "fread") {
    data <- fread(url,
                  sep = "|",
                  na.strings = c("", "NA", "NaN"),
                  showProgress = FALSE) %>%
      tibble() %>%
      select(ICULOS, HR, Temp, Resp, SepsisLabel) %>%
      mutate(across(-Temp, as.integer),
             Temp = as.numeric(Temp),
             PatientID = ptid_string) %>%
      select(PatientID, everything())
  } else if (read_function == "read_delim") {
    data <- read_delim(url,
                       delim = "|",
                       na = c("", "NA", "NaN")) %>%
      select(ICULOS, HR, Temp, Resp, SepsisLabel) %>%
      mutate(across(-Temp, as.integer),
             Temp = as.numeric(Temp),
             PatientID = ptid_string) %>%
      select(PatientID, everything())
    
  }
  
  return(data)
}

makeSepsisDataset <- function(n = 50, read_fn = "fread") {
  ptids <- sample(1:10000, n, replace = FALSE)

  sepsis_data <- map_dfr(ptids, getPatient, read_function = read_fn) %>%
    filter(ICULOS > 1) %>%
    group_by(PatientID) %>%
    mutate(ICULOS = ICULOS - min(ICULOS)) %>%
    mutate(obsTime = Sys.time() + c(0, sort(runif(n()-1, min(ICULOS), max(ICULOS))*3600))) %>%
    arrange(PatientID)
  
  return(sepsis_data)
}

updateData <- function(drive_url) {
  data <- drive_read_string(drive_url) %>%
    read_csv()
  
  updated_data <- data %>%
    filter(obsTime < Sys.time())
  
  return(updated_data)
}

create_plot <- function(pid) {
  df_filtered <- new_data %>% filter(PatientID == pid)
  p <- ggplot(df_filtered, aes(x = time)) +
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
    ggtitle(paste("Patient ID:", pid))
  return(p)
}

