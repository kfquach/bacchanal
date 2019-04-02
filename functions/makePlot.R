ggplot(q) + 
  geom_point(aes(y = reorder(tickers, current.change), x = rf.pred), color = "darkgreen") + 
  geom_point(aes(y = reorder(tickers, current.change), x = lass.pred), color = "red") + 
  geom_point(aes(y = reorder(tickers, current.change), x = current.change), color = "black") + 
  ggtitle("Market next-day prediction with model performance greater than R^2 of 0.50 from rf model") + 
  scale_y_discrete("Ticker symbol") +
  scale_x_continuous("Ticker change % in most recent day") +
  theme_bw()