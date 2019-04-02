# getTickerDaily.R using Tiingo API

tickerData <- list()
startdate = '2018-01-01'
enddate = '2018-09-30'

riingo_set_token(token = '<insert api key>')

for (i in 369:length(tech_tickers)){
  
  tickerData[[i]] <- riingo_prices(tech_tickers[i], start_date = startdate, end_date = enddate, resample_frequency = "daily")
  Sys.sleep(1)
  print(paste0("Retrieved ", tech_tickers[i]))
  
}
# 
# ticker_update_DF <- do.call(rbind, tickerData)
# 
# load("data/ticker_daily.RData")
# 
# ticker_daily_DF <- rbind(ticker_daily_DF, ticker_update_DF)
# save(ticker_daily_DF, file = "data/ticker_daily.RData")