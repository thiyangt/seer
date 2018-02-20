#' Autocorrelation-based features
#'
#' Computes various measures based on autocorrelation coefficients of the
#' original series, first-differenced series and second-differenced series
#' @param x a univariate time series
#' @return A vector of 3 values: sum of squared of first five autocorrelation coefficients of original series, first-differenced series,
#' and twice-differenced series.
#' @author Thiyanga Talagala
#' @export
acf5 <- function(x){
  acfx <- acf(x, lag.max = 5L, plot = FALSE, na.action = na.pass)
  acfdiff1x <- acf(diff(x, 1), lag.max = 5L, plot = FALSE,
                   na.action = na.pass)
  acfdiff2x <- acf(diff(x, 2), lag.max = 5L, plot = FALSE,
                   na.action = na.pass)

  sum_of_sq_acf5 <- sum((acfx$acf[2L:6L])^2)
  diff1_acf5 <- sum((acfdiff1x$acf[2L:6L])^2)
  diff2_acf5 <- sum((acfdiff2x$acf[2L:6L])^2)
  output <- c(y_acf5 = unname(sum_of_sq_acf5),
              diff1y_acf5 = unname(diff1_acf5),
              diff2y_acf5 = unname(diff2_acf5))
  return(output)

}
