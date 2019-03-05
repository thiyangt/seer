#' Convert multiple frequency time series into msts object
#'
#' Convert multiple frequency(daily, hourly, half-hourly, minutes, seconds)
#' time series into msts object.
#' @param y univariate time series
#' @param category frequency data have been collected
#' @return a ts object or msts object
#' @export
convert_msts <- function(y, category){
switch(category,
daily={
    if( length(y) <= 2*366){
      y <- ts(y, frequency = 7)
    } else {
      y <- forecast::msts(y, seasonal.periods=c(7, 365.25))
    }
},
hourly={
  if (length(y) > 2*8766){
    y <- forecast::msts(y, seasonal.periods=c(24, 168, 8766))
  } else if( 2*168 < length(y) & length(y) <= 2*8766) {
    y <- forecast::msts(y, seasonal.periods=c(24, 168))
  } else {
    y <- ts(y, frequency=24)
  }
}
)
return(y)
}
#'@examples
#'library(seer)
#'data(M4)
#'M4_daily <- subset(M4, "daily")
#'length(M4_daily[[1]]$x)
