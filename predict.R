setwd("~/Documents/bacchanal/")

rm(list=ls())

library(tidyverse)
library(reshape2)
library(jsonlite)
library(lubridate)
library(MMWRweek)
library(ranger)
library(data.table)

# Functions
source("functions/setUpBacchanal.R")
source("functions/makeDateFeatures.R")

# Load Data
dat <- setUpBacchanal()

# Data Processing: List of Active Tickers For Prediction
tickers <- gsub("diff_", "", grep(pattern = "diff", x = names(dat), value = TRUE))

# Training Date
# trainDateList = c("2019-01-28", "2019-02-15", "2019-03-15")

####################################################################
# Model 1: Predicting stock price direction
####################################################################

# Results Record
aucList <- matrix(nrow = length(tickers), ncol = 4,
                  dimnames = list(c(),
                                  c("tickers", "mtry", "pred.error", "test.accuracy")))
aucList[,1] <- tickers

trainDate <- "2019-03-01"

# Train random forest using ranger
for (i in 1:length(tickers)){
  
  # get ticker
  tickerSelect <- paste0("diff_", tickers[i])
  
  # define outcome variable + turn into factor
  t <- dat
  t$dir <- t[[tickerSelect]]
  t$dir <- ifelse(t$dir > 0, 1, 0)
  t$dir <- factor(t$dir,
                  levels = c("0", "1"),
                  labels = c("Down", "Up"))
  
  t[[tickerSelect]] <- NULL
  
  # Remove duplicates
  t <- t[,colSums(is.na(t[,-ncol(t)])) == 0]
  
  # separate data set
  train <- t %>% filter(date <= trainDate) %>% select(-date)
  test <- t %>% filter(date > trainDate) %>% select(-date)
  
  # skip to next loop if no variance in outcome
  if (length(unique(as.character(train$dir))) == 1){next}
  
  # skip to next loop if too few dates available
  if (sum(is.na(train)) > 100){next}
  train <- train %>% na.omit()
  
  # build model
  rf.model <- ranger(dir ~ ., data = train)
  
  # predict
  pred <- predict(rf.model, test)
  
  # results
  aucList[i,2] <- rf.model$mtry
  aucList[i,3] <- rf.model$prediction.error
  aucList[i,4] <- mean(pred$predictions == test$dir, na.rm = TRUE)
  
  # print message
  print(paste0(Sys.time(),
               " - Finished ",
               tickers[i], " modeling with ",
               nrow(train), " training observations. Test accuracy is ",
               aucList[i,4]))
  
}

# save(aucList, "data/classificationResults.RData")

####################################################################
# Model 2: Predicting stock price percentage change
####################################################################

regResults <- matrix(nrow = length(tickers), ncol = 7,
                     dimnames = list(c(),
                                     c("tickers", "dir.correct", "pred.error", "r.squared", "rf.pred", "lass.pred", "current.change")))
regResults[,1] <- tickers

trainDate <- "2019-03-01"

set.seed(20190401)

# Train random forest using ranger
for (i in 1:length(tickers)){
  
  # get ticker
  tickerSelect <- paste0("diff_", tickers[i])
  
  # define outcome variable + turn into factor
  t <- dat
  t$dir <- t[[tickerSelect]]
  t[[tickerSelect]] <- NULL
  
  # Remove columns with too many missing values
  t <- t[,colSums(is.na(t[,-ncol(t)])) < 25]
  
  # Remove dates with missing data
  t <- t %>% na.omit()
  
  # Scale Features
  t[,2:(ncol(t) - 22)] <- lapply(t[,2:(ncol(t) - 22)], scale)
  
  # separate data set
  train <- t %>% filter(date <= trainDate) %>% select(-date)
  test <- t %>% filter(date > trainDate) %>% select(-date)
  lastObs <- test[nrow(test),]
  
  # skip to next loop if no variance in outcome
  if (length(unique(as.character(train$dir))) == 1){next}
  
  # skip to next loop if too few dates available
  if (sum(is.na(train)) > 100){next}
  train <- train %>% na.omit()
  
  # build model - ranger
  ########################################################
  rf.model <- ranger(dir ~ ., data = train)
  
  # print message
  print(paste0(Sys.time(), " - Finished training RFmodel for ", tickers[i]))
  
  # predict - rf
  pred <- predict(rf.model, test)
  predLast <- predict(rf.model, lastObs)
  
  # build model - lasso
  ########################################################
  ytrain <- train$dir
  xtrain <- as.matrix(train %>% select(-dir))
  
  ytest <- test$dir
  xtest <- as.matrix(test %>% select(-dir))
  
  cv.out <- glmnet::cv.glmnet(x = xtrain, y = ytrain, alpha = 1)
  bestlam <- cv.out$lambda.min
  
  # print message
  print(paste0(Sys.time(), " - Finished training lasso model for ", tickers[i]))
  
  lasso.pred <- predict(cv.out, s = bestlam, newx = xtest)
  lasso.predLast <- predict(cv.out, s = bestlam, newx = as.matrix(lastObs %>% select(-dir)))
  
  # results - percentage of positive directions at same time (value of 1 is perfect, 
  # less than 1 implies more positive in truth, more than 1 implies less positive in truth)
  dir.correct <- sum(pred$predictions[1:19] > 0)/sum(test$dir > 0, na.rm = TRUE)
  regResults[i,2] <- dir.correct
  regResults[i,3] <- rf.model$prediction.error
  regResults[i,4] <- round(rf.model$r.squared,3)
  regResults[i,5] <- round(as.numeric(predLast$predictions),3)
  regResults[i,6] <- round(as.numeric(lasso.predLast),3)
  regResults[i,7] <- round(as.numeric(quantmod::getQuote(tickers[i])[4]),2)
  
  # print message
  print(paste0(Sys.time(),
               " - Finished ",
               tickers[i], " modeling with ",
               nrow(train), " training observations. RSquared is ",
               regResults[i,4]))
  
}