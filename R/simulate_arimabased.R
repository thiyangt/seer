#' Simulate time series based on ARIMA models
#'
#' simulate multiple time series for a given series based on ARIMA models
#' @param y a time series or M-competition data time series (Mcomp)
#' @param Nsim number of time series to simulate
#' @param Combine if TRUE, training and test data in the M-competition data are combined and generate a time
#' series corresponds to the full length of the series. Otherwise, it generate a time series
#' based on the training period of the series.
#' @param M if TRUE, y is considered to be a Mcomp data object
#' @param Future  So if future=TRUE, the simulated observations are conditional on the historical observations.
#' In other words, they are possible future sample paths of the time series. But if future=FALSE, the historical
#' data are ignored, and the simulations are possible realizations of the time series model that
#' are not connected to the original data.
#' @param Length length of the simulated time series. If future = FALSE, the Length agument should be NA.
#' @return A list of time series.
#' @author Thiyanga Talagala
#' @export
sim_arimabased <- function(y, Nsim, Combine=TRUE, M=TRUE, Future=FALSE, Length=NA){
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
  fit <- forecast::auto.arima(combined)
  if (!is.na(Length)){length_series <- Length
  } else {
  length_series <- length(combined)
  }
  mat <- list()
  for(i in 1:Nsim){
    mat[[i]] <- simulate(fit, nsim=length_series, future=Future)}
  return (mat)
}
#'@examples
#'require(Mcomp)
#'quaterly_m3 <- subset(M3, "yearly")
#'sim_arimabased(quarterly_m3[[1]], 2, Combine=TRUE, M=TRUE, Future=FALSE)
#'
#'set.seed(1)
#'tsy <- ts(rnorm(8), frequency=1)
#'sim_arimabased(tsy, 2, Combine=FALSE, M=FALSE, Future=TRUE, Length=5)
