# getTickers.R 

# List of total tickers in NYSE and NASDAQ obtained from https://www.nasdaq.com/screening/company-list.aspx
nyse   <- read.csv("companylist (1).csv", stringsAsFactors = F)
nasdaq <- read.csv("companylist (2).csv", stringsAsFactors = F)
tickers <- rbind(nyse, nasdaq) %>% arrange(Symbol)

# Market Cap Unit
tickers$unit <- ifelse(substr(x = tickers$MarketCap, start = nchar(tickers$MarketCap), stop = nchar(tickers$MarketCap)) == "B", "Billions", 
                       ifelse(substr(x = tickers$MarketCap, start = nchar(tickers$MarketCap), stop = nchar(tickers$MarketCap)) == "M", "Millions", ""))
tickers$mcap <- as.numeric(gsub("\\$|B|M", "", tickers$MarketCap))
tickers$mcap <- ifelse(tickers$unit == "Billions", tickers$mcap*1000, tickers$mcap)