# getTickerDataPulled

getTickerDataPulled <- function(volume){

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
  
  if (volume == "No"){
    ## Delta is the percentage change of a tech ticker in a day
    t <- ticker_daily_DF %>% mutate(delta = (close - open)*100/open) %>% select(ticker, date, delta)
    t <- t[!duplicated(t[,c("ticker", "date")]),]
    t <- t %>% dcast(date ~ ticker, value.var = "delta")
  } else {
    t <- ticker_daily_DF %>% mutate(delta = (close - open)*100/open) %>% select(ticker, date, volume, delta)
    t <- t[!duplicated(t[,c("ticker", "date", "volume")]),]
    
    delta <- t %>% dcast(date ~ ticker, value.var = c("delta"))
    names(delta) <- paste0("delta_", names(delta))
    
    volume <- t %>% dcast(date ~ ticker, value.var = c("volume"))
    names(volume) <- paste0("volume_", names(volume))
    
    t <- cbind(delta, volume[-1])
  }
  
  return(t)
  
}