#' split a time series into training and test set
#'
#'the function head_ts extract the training set of a time series
#'@param y a univariate time series
#'@param h length of the forecast horizon
#'@author Thiyanga Talagala
#'@import forecast
#'@import stats
#'@return a univariate time series
#'@export
head_ts <- function(y, h){
  if(!is.ts(y))
    y <- stats::ts(y, frequency=forecast::findfrequency(y))
  endy <- stats::end(y)
  stats::window(y, end=c(endy[1],endy[2]-h))
}
#'@examples
#'require(Mcomp)
#'quarterly_m3 <- subset(M3, "quarterly")
#'head_ts(quarterly_m3[[1]]$y, h=8)
