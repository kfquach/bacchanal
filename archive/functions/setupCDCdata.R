setupCDCdata <- function(){
  
  load(file = "data/flu_data.RData")

  # Data Source: Get CDC data
  fs_nat <- hospitalizations("flusurv")
  q <- fs_nat %>% dcast(year + year_wk_num ~ age, value.var = "weeklyrate")
  names(q) <- c("year", "year_wk_num", "fluGroup1", "fluGroup2", "fluGroup3", "fluGroup4", "fluGroup5", "fluGroup6")
  
  # Data Source: Merge with CDC
  
  t <- t %>% 
    left_join(q, by = c("year", "year_wk_num")) %>%
    select(-dayOfWeek, -month)
  
}