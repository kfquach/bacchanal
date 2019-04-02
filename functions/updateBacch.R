updateBacch <- function(){
  
  load(file = "data/quantmod_ticker.RData")
  
  # Get Tickers - Script to pull data: source("getTickers.R") ##
  load("data/tickers.RData")
  
  # Tech Tickers
  tech_tickers <- tickers %>% filter(!is.na(mcap)) %>% filter(unit != "") %>% filter(Sector %in% c("Technology")) %>% filter(!is.na(mcap)) %>% filter(mcap > 500)
  tech_tickers <- tech_tickers$Symbol
  
  # Matrix Store
  datUpdate <- matrix(ncol = 3, nrow = length(tech_tickers), dimnames = list(c(), c("date", "symbol", "volume", "close")))
  
  for (i in 1:length(tech_tickers)){
  
    tickerInfo <- quantmod::getQuote(tech_tickers[i])
    datUpdate[i,2] <- tech_tickers[i]
    datUpdate[i,3] <- as.numeric(tickerInfo[8])
    datUpdate[i,4] <- as.numeric(tickerInfo[2])
    
    Sys.sleep(1)
    print("Completed ")
    
  }
  
  datUpdate <- datUpdate %>% data.frame(stringsAsFactors = F)
  datUpdate$date <- Sys.Date()
  
  # Update dat
  q <- plyr::rbind.fill(dat, datUpdate) %>% arrange(symbol, desc(date))
 
}