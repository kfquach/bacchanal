setwd("~/Documents/tickers/")

rm(list=ls())

library(tidyverse)
library(reshape2)
library(riingo)
library(jsonlite)
library(kml3d)

#################################################
# Data Sources
#################################################

# Earnings Calendar - Script to pull data: source("getEarningsCal.R") ##
load("data/earnings_cal.RData")
# Get Tickers - Script to pull data: source("getTickers.R") ##
load("data/tickers.RData")

# Tech Tickers
tech_tickers <- tickers %>% filter(Sector == "Technology") %>% filter(!is.na(mcap)) %>% filter(mcap > 500)
tech_tickers <- tech_tickers$Symbol

# Querying daily ticker data
load("data/ticker_daily.RData")

# Normalize ticker_daily_DF
## Delta is the percentage change of a tech ticker in a day
t <- ticker_daily_DF %>% mutate(delta = (close - open)*100/open) %>% select(ticker, date, delta)
t <- t[!duplicated(t[,c("ticker", "date")]),]
t <- t %>% dcast(ticker ~ date)

#################################################
# Clustering - 2D
## Clustering based off of percentage value changes daily of each ticker
#################################################

# Set data frame to a matrix 
traj <- as.matrix(t[,-1])

# Set clustering object for kml longitudinal
tCl <- clusterLongData(
  traj = traj,
  idAll = as.character(t$ticker)
)

# Number of clusters set at 20
kml(object = tCl, nbClusters = c(3,6,9,12,15,18,21))

# Explore how tech tickers are clustered
results <- data.frame(ticker = t$ticker,
           cluster_03 = getClusters(tCl, 3),
           cluster_06 = getClusters(tCl, 6),
           cluster_09 = getClusters(tCl, 9),
           cluster_12 = getClusters(tCl, 12),
           cluster_15 = getClusters(tCl, 15),
           cluster_18 = getClusters(tCl, 18),
           cluster_21 = getClusters(tCl, 21)
)

# Review some known clusters
sub_results <- results %>% filter(ticker %in% c("CRM", "TEAM", "MDB", "TWLO", "BILI", "AAPL", "GOOG", "FB", "TWTR", "NFLX"))

#################################################
# Clustering - 3D
## Clustering based off of percentage value changes daily of each ticker AND trade volume
#################################################

t <- ticker_daily_DF %>% mutate(delta = (close - open)*100/open) %>% select(ticker, date, volume, delta)
t <- t[!duplicated(t[,c("ticker", "date", "volume")]),]
delta <- t %>% dcast(ticker ~ date, value.var = c("delta"))
volume <- t %>% dcast(ticker ~ date, value.var = c("volume"))

t3d <- cbind(delta, volume[-1])

# 3d cluster object
tCl3d <- clusterLongData3d(
  traj = t3d,
  timeInData = list(delta = 2:113, volume = 114:227)
)

kml3d(tCl3d, nbClusters = c(12,15,18,21))

# Explore how tech tickers are clustered
results <- data.frame(ticker = t3d$ticker,
                      cluster_12 = getClusters(tCl3d, 12),
                      cluster_15 = getClusters(tCl3d, 15),
                      cluster_18 = getClusters(tCl3d, 18),
                      cluster_21 = getClusters(tCl3d, 21)
)

# Review some known clusters
sub_results <- results %>% filter(ticker %in% c("CRM", "TEAM", "MDB", "TWLO", "BILI", "AAPL", "GOOG", "FB", "TWTR", "NFLX"))
choice(tCl3d)