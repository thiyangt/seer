#'Mean Absolute Scaled Error(MASE)
#'
#'Calculation of mean absolute scaled error
#'@param training training peiod of the time series
#'@param test test period of the time series
#'@param forecast forecast values of the series
#'@return returns a single value
#'@author Thiyanga Talagala
#'@export
cal_MASE <- function(training, test, forecast){

 m <- frequency(training)
 q_t <- abs(test-forecast)/mean(abs(diff(training, lag=m)))
 return(mean(q_t))
}
#'example
#'require(Mcomp)
#'require(seer)
#'require(magrittr)
#'ts <- M3[[1]]$x
#'fcast_arima <- auto.arima(ts) %>% forecast(h=6)
#'cal_MASE(M3[[1]]$x, M3[[1]]$xx, fcast_arima$mean)

