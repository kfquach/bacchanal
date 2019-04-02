makeDateFeatures <- function(data){
  
  data <- data %>% 
    
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
      
    ) %>% 
    
    select(-dayOfWeek)
  
}