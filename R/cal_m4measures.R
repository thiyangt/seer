#'Mean of MASE and sMAPE
#'
#'Calculate MASE and sMAPE for an individual time series
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
#'cal_m4measures(M3[[1]]$x, M3[[1]]$xx, fcast_arima$mean)
cal_m4measures <- function(training, test, forecast){
  method_MASE <- cal_MASE(training, test, forecast)
  method_sMAPE <- cal_sMAPE(training, test, forecast)
  measures <- c(MASE=method_MASE, sMAPE=method_sMAPE)
  return(measures)
}
