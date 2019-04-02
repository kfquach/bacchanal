# getEarningsCal

dateList <- seq.Date(from = as.Date("2018-10-01"), to = as.Date("2019-03-15"), by = 1)
dateList <- gsub("-", "", dateList)

earningsList <- list()

now <- proc.time()
for (i in 1:length(dateList)){
  earn <- read_json(paste0("https://api.earningscalendar.net/?date=", dateList[i]))
  earningsList[[i]] <- suppressWarnings(do.call(rbind_list, earn)) %>% mutate(date = dateList[i])
  print(paste0("Retrieved ", dateList[i]))
  Sys.sleep(0.5)
}
proc.time() - now

earningsDF <- do.call(rbind, earningsList)