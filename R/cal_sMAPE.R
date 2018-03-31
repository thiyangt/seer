#'symmetric Mean Absolute Pecentage Error(sMAPE)
#'
#'Calculation of symmetric mean absolute percentage error
#'@param training training peiod of the time series
#'@param test test period of the time series
#'@param forecast forecast values of the series
#'@return returns a single value
#'@author Thiyanga Talagala
#'@export
cal_sMAPE <- function(training, test, forecast){

  q_t <- 2*(abs(test-forecast))/(abs(test)+abs(forecast))
  mean(q_t)
}
#'example
#'require(Mcomp)
#'require(seer)
#'require(magrittr)
#'ts <- M3[[1]]$x
#'fcast_arima <- auto.arima(ts) %>% forecast(h=6)
#'cal_sMAPE(M3[[1]]$x, M3[[1]]$xx, fcast_arima$mean)
