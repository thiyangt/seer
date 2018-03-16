#' extract the test set of time series
#'
#'the function tail_ts extract the test set of a time series
#'@param y a univariate time series
#'@param h length of the forecast horizon
#'@author Thiyanga Talagala
#'@import forecast
#'@import stats
#'@return a univariate time series of length h
#'@export
tail_ts <- function(y, h){
  if(!is.ts(y))
    y <- stats::ts(y, frequency=forecast::findfrequency(y))
  endy <- stats::end(y)
  stats::window(y, start=c(endy[1],endy[2]-(h-1)), end=endy)
}
#'@examples
#'require(Mcomp)
#'quarterly_m3 <- subset(M3, "quarterly")
#'tail_ts(quarterly_m3[[1]]$y, h=8)
