#' Simulate time series based on ETS models
#'
#' simulate multiple time series for a given series based on ETS models
#' @param y a time series or M-competition data time series (Mcomp)
#' @param Nsim number of time series to simulate
#' @param Combine if TRUE, training and test data in the M-competition data are combined and generate a time
#' series corresponds to the full length of the series. Otherwise, it generate a time series
#' based on the training period of the series.
#' @param M if TRUE, y is considered to be a Mcomp data object
#' @return A list of time series.
#' @author Thiyanga Talagala
#' @import forecast
#' @export
sim_etsbased <- function(y, Nsim, Combine=TRUE, M=TRUE){
  if (M ==TRUE){
    if ("Combine"==TRUE){
      train <- y$x
      test <-  y$xx
      combined <- ts.union(train, test)
      combined <- pmin(combined[,1], combined[,2], na.rm = TRUE)
    }else{
      combined <- y$x}
  }else{
    combined <- y
  }
  fit <- ets(combined)
  length_series <- length(combined)
  mat <- list()
  for(i in 1:Nsim){
    mat[[i]] <- simulate(fit, nsim=length_series, future=FALSE)}
  return (mat)
}
#'@examples
#'require(Mcomp)
#'libray(seer)
#'quaterly_m3 <- subset(M3, "yearly")
#'sim_etsbased(quarterly_m3[[1]], 2, Combine=TRUE, M=TRUE)
#'
#'set.seed(1)
#'tsy <- ts(rnorm(8), frequency=1)
#'sim_etsbased(tsy, 2, Combine=FALSE, M=FALSE)
