## keep everything below this line

library(tictoc)

source("sepsis_monitor_functions.R")
  tic.clear()
  tic.clearlog()


# 50 patient lists
tic()
df_50.delim <- makeSepsisDataset(n = 50, 
                                 read_fn = "read_delim")
toc(log = TRUE)


tic()
df_50.fread <- makeSepsisDataset(n = 50, 
                                 read_fn = "fread")
toc(log = TRUE)

## 100 patient lists
tic()
df_100.delim <- makeSepsisDataset(n = 100, 
                                  read_fn = "read_delim")
toc(log = TRUE)


tic()
df_100.fread <- makeSepsisDataset(n = 100, 
                                  read_fn = "fread")
toc(log = TRUE)

## 500 patient list
# tic()
# df_500.delim <- makeSepsisDataset(n = 500, 
#                                   read_fn = "read_delim")
# toc(log = TRUE)


tic()
df_500.fread <- makeSepsisDataset(n = 500, 
                                  read_fn = "fread")
toc(log = TRUE)

# manipulating data to create a tidy table output

toc_table <- tic.log() %>% # Access time measurements and extract elapsed times
  unlist(recursive = TRUE) %>%
  as.data.frame() %>%
  rename("Time Elapsed" = ".")

toc_table2 <- toc_table %>%
  mutate(Iteration = c("n = 50, delim",
                       "n = 50, fread",
                       "n = 100, delim",
                       "n = 100, fread",
                       # "n = 500, delim",
                       "n = 500, fread"),
         .before = "Time Elapsed")

# tidy table output
kable(toc_table2)
