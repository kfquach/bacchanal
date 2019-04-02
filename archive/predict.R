setwd("~/Documents/tickers/")

rm(list=ls())

library(tidyverse)
library(reshape2)
library(riingo)
library(jsonlite)
library(kml3d)
library(lubridate)
library(cdcfluview)
library(MMWRweek)
library(ranger)
library(missRanger)

######################################################
# Get Ticker Data Pulled
######################################################

source("functions/getTickerDataPulled.R")

ticker_daily_DF[1:5,1:5]

ticker_daily_DF <- getTickerDataPulled(volume = "Yes")
ticker_daily_DF <- rename(.data = ticker_daily_DF, date = delta_date)

# Remove Tickers with too many missing values
ticker_daily_DF <- ticker_daily_DF[, colSums(is.na(ticker_daily_DF)) < 10]

# Get CDC data

fs_nat <- hospitalizations("flusurv")
q <- fs_nat %>% dcast(year + year_wk_num ~ age, value.var = "weeklyrate")
names(q) <- c("year", "year_wk_num", "fluGroup1", "fluGroup2", "fluGroup3", "fluGroup4", "fluGroup5", "fluGroup6")

# Create Calendar Features

t <- ticker_daily_DF %>% 
  
  mutate(
    year = year(date),
    month = month(date),
    dayOfWeek = weekdays(date),
    year_wk_num = MMWRweek(date)[[2]]
  ) %>%
  
  mutate(
    jan = ifelse(month == 1, 1, 0),
    feb = ifelse(month == 2, 1, 0),
    mar = ifelse(month == 3, 1, 0),
    apr = ifelse(month == 4, 1, 0),
    may = ifelse(month == 5, 1, 0),
    jun = ifelse(month == 6, 1, 0),
    jul = ifelse(month == 7, 1, 0),
    aug = ifelse(month == 8, 1, 0),
    sep = ifelse(month == 9, 1, 0),
    oct = ifelse(month == 10, 1, 0),
    nov = ifelse(month == 11, 1, 0),
    dec = ifelse(month == 12, 1, 0)
    
  ) %>%
  
  mutate(
    monday = ifelse(dayOfWeek == "Monday", 1, 0),
    tuesday = ifelse(dayOfWeek == "Tuesday", 1, 0),
    wednesday = ifelse(dayOfWeek == "Wednesday", 1, 0),
    thursday = ifelse(dayOfWeek == "Thursday", 1, 0),
    friday = ifelse(dayOfWeek == "Friday", 1, 0)
    
  )

# Merge with CDC

t <- t %>% 
  
  left_join(q, by = c("year", "year_wk_num")) %>%
  
  select(-dayOfWeek, -month)

# Data Imputation

t <- missRanger(t, maxiter = 3)

##########################################
# Dataset Preparation
##########################################

trainDate <- "2019-02-28"

train <- t %>% filter(date <= trainDate) %>% select(-date)
test <- t %>% filter(date > trainDate) %>% select(-date)

# Train random forest using ranger

rf.model <- randomForest::randomForest(formula = delta_TWLO ~ ., data = train, importance = TRUE)
pred.TWLO <- predict(rf.model, test)

q <- randomForest::importance(rf.model)

comparison <- data.frame(cbind(pred = pred.TWLO, actu = test$delta_TWLO, date = as.Date(test$date, format = "%Y-%m-%d")), stringsAsFactors = F)
comparison <- comparison %>% 
  mutate(sameDirection = case_when(
    pred > 0 & actu > 0 ~ 1,
    pred < 0 & actu < 0 ~ 1,
    pred > 0 & actu < 0 ~ 0,
    pred < 0 & actu > 0 ~ 0
  ))