#'Mean of MASE and sMAPE
#'
#'Calculate mean of MASE and sMAPE for an individual time series
#'
#'@param training training period of a time series
#'@param test test peiod of a time series
#'@param forecast forecast obtained from a fitted to the training period
#'@return returns a single value: mean on MASE and sMAPE
#'@author Thiyanga Talagala
#'@export
#'@examples
#'require(Mcomp)
#'require(magrittr)
#'ts <- M3[[1]]$x
#'fcast_arima <- auto.arima(ts) %>% forecast(h=6)
#'cal_avg(M3[[1]]$x, M3[[1]]$xx, fcast_arima$mean)
cal_avg <- function(training, test, forecast){
  method_MASE <- cal_MASE(training, test, forecast)
  method_sMAPE <- cal_sMAPE(training, test, forecast)
  avg <- mean(c(method_MASE, method_sMAPE))
  return(avg)
}

