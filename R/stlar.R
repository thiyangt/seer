#' STL-AR method
#'
#' STL decomposition method applied to the time series, then an AR model is used to
#' forecast seasonally adjusted data, while the seasonal naive method is used to forecast
#' the seasonal component
#' @param y a univariate time series
#' @param h forecast horizon
#' @param s.window Either the character string “periodic” or the span (in lags) of the loess window for seasonal extraction
#' @param robust logical indicating if robust fitting be used in the loess procedue
#' @return return object of class forecast
#' @author Thiyanga Talagala
#' @import forecast
#' @export
stlar <- function(y, h=10, s.window=11, robust=FALSE)
{
  if(!is.ts(y))
    y <- ts(y, frequency=findfrequency(y))
  if(frequency(y)==1 | length(y) <= 2*frequency(y))
    return(forecast(auto.arima(y, max.q=0), h=h))

  fit_stlm <- stlm(y,s.window=s.window, robust=robust, modelfunction=ar)
  fcast <- forecast(fit_stlm, h=h)
  return(fcast)
}
#'@seealso \code{\link{forecast.stl}}}.
#'@references Hyndman, R, C Bergmeir, G Caceres, M O'Hara-Wild, S Razbash & E Wang(2018). forecast:
#'Forecasting functions for time series and linear models. R package version 8.3.
#'@examples
#'require(Mcomp)
#'stlar(yearly_m1[[1]]$x)
