#' Simulate time series based on multiple seasonal decomposition
#'
#' simulate multiple time series based a given series using multiple seasonal decomposition
#' @param y a time series or M-competition data time series (Mcomp object)
#' @param Nsim number of time series to simulate
#' @param Combine if TRUE, training and test data in the M-competition data are combined and generate a time
#' series corresponds to the full length of the series. Otherwise, it generate a time series
#' based on the training period of the series.
#' @param M if TRUE, y is considered to be a Mcomp data object
#' @param Future if future=TRUE, the simulated observations are conditional on the historical observations.
#' In other words, they are possible future sample paths of the time series. But if future=FALSE, the historical
#' data are ignored, and the simulations are possible realizations of the time series model that
#' are not connected to the original data.
#' @param Length length of the simulated time series. If future = FALSE, the Length agument should be NA.
#' @param mtd method to use for forecasting seasonally adjusted time series
#' @param extralength extra length need to be added for simulated time series
#' @return A list of time series.
#' @author Thiyanga Talagala
#' @export
sim_mstlbased <- function(y, Nsim, Combine=TRUE, M=TRUE, Future=FALSE, Length=NA, extralength=NA, mtd="ets"){
    if (M ==TRUE){
      if (Combine==TRUE){
      train <- y$x
      test <-  y$xx
      combined <- ts.union(train, test)
      combined <- pmin(combined[,1], combined[,2], na.rm = TRUE)
      }else{
      combined <- y$x}
    }else{
      combined <- y
    }

  class_combined <- class(combined)

  if (!("msts" %in% class_combined)==TRUE){

  if(frequency(combined)==1 | length(combined) <= 2*frequency(combined))
    return(NA)
}
  fit <- forecast::stlf(combined, method=mtd)
  if (!is.na(Length)){length_series <- Length
  } else if (!is.na(extralength)) {
    length_series <- length(combined)+extralength
  } else {
    length_series <- length(combined)
  }
  mat <- list()
  for(i in 1:Nsim){
    mat[[i]] <- simulate(fit$model, nsim=length_series, future=Future)}
  return (mat)
}
#'@examples
#'library(seer)
#'data(M4)
#'weekly_m4 <- subset(M4, "weekly")
#'sim_mstlbased(weekly_m4[[1]], 2, Combine=FALSE, M=TRUE, Future=FALSE, mtd="arima")
#'
#'daily_m4 <- subset(M4, "daily") # series with length < 2*frequency
#'sim_mstlbased(daily_m4[[3]], 2, Combine=FALSE, M=FALSE, Future=TRUE, mtd="ets")
