#' Autocorrelation-based features
#'
#' Computes various measures based on autocorrelation coefficients of the
#' original series, first-differenced series and second-differenced series
#' @param y a univariate time series
#' @return A vector of 3 values: sum of squared of first five autocorrelation coefficients of original series, first-differenced series,
#' and twice-differenced series.
#' @author Thiyanga Talagala
#' @export
acf5 <- function(y){
  acfy <- stats::acf(y, lag.max = 5L, plot = FALSE, na.action = na.pass)
  acfdiff1y <- stats::acf(diff(y, 1), lag.max = 5L, plot = FALSE,
                   na.action = na.pass)
  acfdiff2y <- stats::acf(diff(y, 2), lag.max = 5L, plot = FALSE,
                   na.action = na.pass)

  sum_of_sq_acf5 <- sum((acfy$acf[2L:6L])^2)
  diff1_acf5 <- sum((acfdiff1y$acf[2L:6L])^2)
  diff2_acf5 <- sum((acfdiff2y$acf[2L:6L])^2)
  output <- c(y_acf5 = unname(sum_of_sq_acf5),
              diff1y_acf5 = unname(diff1_acf5),
              diff2y_acf5 = unname(diff2_acf5))
  return(output)

}
