#' split a time series into training and test set
#'
#'the function head.ts extract the training set of a time series
#'@param y a univariate time series
#'@param h length of the forecast horizon
#'@author Thiyanga Talagala
#'@import forecast
#'@return a univariate time series
#'@export
#'@examples
#'require(Mcomp)
#'quarterly_m3 <- subset(M3, "quarterly")
#'head.ts(quarterly_m3[[1]]$x, h=8)
head.ts <- function(x, h){
  if(!is.ts(x))
    x <- ts(x, frequency=forecast::findfrequency(x))
  endx <- end(x)
  window(x, end=c(endx[1],endx[2]-h))
}


#' extract the test set of time series
#'
#'the function tail.ts extract the test set of a time series
#'@param y a univariate time series
#'@param h length of the forecast horizon
#'@author Thiyanga Talagala
#'@import forecast
#'@return a univariate time series of length h
#'@export
#'@examples
#'require(Mcomp)
#'quarterly_m3 <- subset(M3, "quarterly")
#'tail.ts(quarterly_m3[[1]]$x, h=8)
tail.ts <- function(x, h){
  if(!is.ts(x))
    x <- ts(x, frequency=forecast::findfrequency(x))
  endx <- end(x)
  window(x, start=c(endx[1],endx[2]-(h-1)), end=endx)
}

