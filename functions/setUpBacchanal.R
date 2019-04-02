setUpBacchanal <- function(){
  
  # Data Source: Get Ticker Data
  load(file = "data/quantmod_ticker.RData")
  dat$date <- as.Date(dat$date)

  # Data Processing: Reshape Data
  dat <- data.table(dat)
  dat <- data.table::dcast(data = dat,
                           formula = date ~ symbol, 
                           value.var = names(dat)[!names(dat) %in% c("date", "symbol")])
  dat <- data.frame(dat, stringsAsFactors = F)
  
  # Drop Columns with Missing Data
  # dat <- dat[, colSums(is.na(dat)) == 0]
  
  # Data Processing: Get calendar dates
  dat <- makeDateFeatures(dat)
  
  # Data Processing: MMWR Week
  dat$MMWRWeek <- MMWRweek(dat$date)[[2]]
  
  return(dat)
  
}