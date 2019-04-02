rm(list=ls())

library(tidyverse)
library(lubridate)
library(quantmod)
library(TTR)

# Get Tickers - Script to pull data: source("getTickers.R") ##
load("data/tickers.RData")

# Tech Tickers
tech_tickers <- tickers %>% filter(!is.na(mcap)) %>% filter(unit != "") %>% filter(Sector %in% c("Technology")) %>% filter(!is.na(mcap)) %>% filter(mcap > 500)
tech_tickers <- tech_tickers$Symbol

# List
finData <- list()

# Loop
for (i in 1:length(tech_tickers)){
  
  possibleError <- tryCatch(getSymbols(tech_tickers[i], src = "yahoo", auto.assign = FALSE),
           error = function(e) e)
  
  if (!inherits(possibleError, "error")){
    t <- getSymbols(tech_tickers[i], src = "yahoo", auto.assign = FALSE)
  } else next
  
  t <- getSymbols(tech_tickers[i], src = "yahoo", auto.assign = FALSE)
  
  print(paste0(Sys.time(), " - Retrieved ", tech_tickers[i]))
  
  t <- as.data.frame(t)
  t <- t %>% na.omit()
  
  # date
  t$date <- rownames(t)
  
  # day change
  t$diff <- (lag(t[,4]) - t[,4])
  t$diff <- ifelse(t$diff > 0, 1, 0)
  
  # simple moving average
  t$SMA_5_Close <- SMA(t[,4], n = 5)
  t$SMA_8_Close <- SMA(t[,4], n = 8)
  t$SMA_13_Close <- SMA(t[,4], n = 13)
  t$SMA_21_Close <- SMA(t[,4], n = 21)
  
  # exponential moving average
  t$EMA_12_Close <- EMA(t[,4], n = 12)
  t$EMA_26_Close <- EMA(t[,4], n = 26)
  
  # relative strength index
  t$RSI_14_Close <- RSI(t[,4], n = 14)
  
  # williams %r
  t$w <- as.numeric(WPR(t[,4]))
  
  # symbol
  t$symbol <- gsub(x = names(t)[1], pattern = ".Open", replacement = "")
  
  # rename variables
  t$close <- t[,1]
  t$volume <- t[,2]
    
  # select variables
  t <- t[,c(7:19)]
  
  # eliminate missing
  t <- t %>% na.omit() %>% filter(year(as.Date(date)) >= 2017)
  
  finData[[tech_tickers[i]]] <- t
  
}

dat <- do.call(plyr::rbind.fill, finData)

save(dat, file = "data/quantmod_ticker.RData")
