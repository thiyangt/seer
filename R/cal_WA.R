#'Weighted Average
#'
#'Weighted Average(WA) calculated based on MASE, sMAPE for an individual time series
#'
#'@param training training period of a time series
#'@param test test peiod of a time series
#'@param forecast forecast obtained from a fitted to the training period
#'@return returns a single value: WA based on MASE and sMAPE
#'@author Thiyanga Talagala
#'@export
cal_WA <- function(training, test, forecast){
  snaive_fcast <- snaive(training, length(test))$mean
  snaive_MASE <- cal_MASE(training, test, snaive_fcast)
  snaive_sMAPE <- cal_sMAPE(training, test, snaive_fcast)
  if (is.nan(snaive_MASE)==TRUE| is.nan(snaive_sMAPE)==TRUE){
    return(NaN)
  } else if (snaive_MASE==0| snaive_sMAPE==0){
    return(Inf)
  } else {
    method_MASE <- cal_MASE(training, test, forecast)
    method_sMAPE <- cal_sMAPE(training, test, forecast)
    WA <- mean(c(method_MASE/snaive_MASE, method_sMAPE/snaive_sMAPE))
    return(WA)
  }
}
#'@example
#'require(Mcomp)
#'require(seer)
#'require(magrittr)
#'ts <- M3[[1]]$x
#'fcast_arima <- auto.arima(ts) %>% forecast(h=6)
#'cal_WA(M3[[1]]$x, M3[[1]]$xx, fcast_arima$mean)
