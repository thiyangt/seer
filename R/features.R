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
  acfy <- stats::acf(y, lag.max = 5L, plot = FALSE)
  acfdiff1y <- stats::acf(diff(y, 1), lag.max = 5L, plot = FALSE)
  acfdiff2y <- stats::acf(diff(y, 2), lag.max = 5L, plot = FALSE)

  sum_of_sq_acf5 <- sum((acfy$acf[-1L])^2)
  diff1_acf5 <- sum((acfdiff1y$acf[-1L])^2)
  diff2_acf5 <- sum((acfdiff2y$acf[-1L])^2)
  output <- c(y_acf5 = unname(sum_of_sq_acf5),
              diff1y_acf5 = unname(diff1_acf5),
              diff2y_acf5 = unname(diff2_acf5))
  return(output)

}
#' Autocorrelation coefficient at lag 1 of the residuals
#'
#' Computes the first order autocorrelation of the residual series of the deterministic trend model
#' @param y a univariate time series
#' @return A numeric value.
#' @author Thiyanga Talagala
#' @export
e_acf1 <- function(y){
  n <- length(y)
  time <- 1:n
  linear_mod <- stats::lm(y~time)
  Res <- stats::resid(linear_mod)
  lmres_acf1 <- stats::acf(Res,lag.max=1,plot=FALSE)$acf[-1]
  output <- c(lmres_acf1 = unname(lmres_acf1))
  return(output)
}
#' Unit root test statistics
#'
#' Computes the test statistics based on unit root tests Phillips–Perron test and
#' KPSS test
#' @param  y a univariate time series
#' @return A vector of 3 values: test statistic based on PP-test and KPSS-test
#' @author Thiyanga Talagala
#' @export
unitroot <- function(y){
    ur_pp <- urca::ur.pp(y, type = "Z-alpha",
                                   model = "constant")@teststat[1]
    ur_kpss <- urca::ur.kpss(y, type = "tau")@teststat[1]

  output <- c(
    ur_pp = unname(ur_pp),
    ur_kpss = unname(ur_kpss))
  return(output)
}
#' Parameter estimates of Holt-Winters seasonal method
#'
#' Estimate the smoothing parameter for the level-alpha and
#' the smoothing parameter for the trend-beta, and seasonality-gamma
#' @param y a univariate time series
#' @return A vector of 3 values: alpha, beta, gamma
#' @author Thiyanga Talagala
#' @export
holtWinter_parameters <- function(y){
  tryCatch({
  fit <- forecast::hw(y)
  output <- c(hwalpha = unname(fit$model$par["alpha"]),
              hwbeta = unname(fit$model$par["beta"]),
              hwgamma = unname(fit$model$par["gamma"]))
  return(output)
  }, error=function(e){return(c(hwalpha=NA, hwbeta=NA, hwgamma=NA))})
}
#' Autocorrelation coefficients based on seasonally differenced series
#'
#' @param y a univariate time series
#' @param m frequency of the time series
#' @param lagmax maximum lag at which to calculate the acf
#' @return A vector of 3 values: first ACF value of seasonally-differenced series, ACF value at the first seasonal lag of seasonally-differenced series,
#' sum of squares of first 5 autocorrelation coefficients of seasonally-differenced series.
#' @author Thiyanga Talagala
#' @export
acf_seasonalDiff <- function(y,m, lagmax){ # monthly lagmax=13L, quarterly lagmax=5L
  sdiff <- diff(y, lag=m, differences=1)
  sEacfy <- stats::acf(sdiff, lag.max = lagmax, plot = FALSE)
  SEacf_1 <- sEacfy$acf[2L]
  SEseas_acf1 <- sEacfy$acf[m+1L]
  SEsum_of_sq_acf5 <- sum((sEacfy$acf[2L:6L])^2, na.rm=TRUE)

  output <- c(
    sediff_acf1 = unname(SEacf_1),
    sediff_seacf1 = unname(SEseas_acf1),
    sediff_acf5 = unname(SEsum_of_sq_acf5))
  return(output)
}
#' Parameter estimates of Holt's linear trend method
#'
#' Estimate the smoothing parameter for the level-alpha and
#' the smoothing parameter for the trend-beta.
#' @param x a univariate time series
#' @return a vector of 2 values: alpha, beta.
#' @author Thiyanga Talagala
#' @export
holt_parameters <- function(x){
  # parameter estimates of holt linear trend model
 # tryCatch({
    fit <- forecast::holt(x)
    output <- c(alpha = unname(fit$model$par["alpha"]),
                beta = unname(fit$model$par["beta"]))
    return(output)
#  }, error=function(e){return(c(alpha=NA, beta=NA))})
}



