#' calculate forecast accuracy from different forecasting methods
#'
#' Calculate forecast accuracy on test set according to a specified criterion
#' @param tslist a list of time series
#' @param models a vector of models to compute
#' @param database whether the time series is from mcomp or other
#' @param accuracyFun function to calculate the accuracy measure, the arguments
#' for the accuracy function should be training, test and forecast
#' @param h forecast horizon
#' @return a list with accuracy matrix, vector of arima models and vector of ets models
#' @author Thiyanga Talagala
#' @export
fcast_accuracy <- function(tslist, models = c("ets", "arima", "rw", "rwd", "wn",
                                         "theta", "stlar", "nn", "snaive", "mstl", "tbats"), database
                           , accuracyFun, h){

  arima_models <- NA
  ets_models <- NA

  if (database == "other") {
   train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
   train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  if ("arima"%in% models) {
    arima_cal <- lapply(train_test, ARIMA, ACCURACY=accuracyFun)
    arima_models <- sapply(arima_cal, function(temp){temp$ARIMAmodel})
  }

  if ("ets"%in% models) {
    ets_cal <- lapply(train_test, ETS, ACCURACY=accuracyFun)
    ets_models <- sapply(ets_cal, function(temp){temp$ETSmodel})
  }


 mat <- sapply(models, function(f){

   switch(f,
          arima = sapply(arima_cal, function(temp){temp$ARIMAaccuracy}),
          ets = sapply(ets_cal, function(temp){temp$ETSaccuracy}),
          rw = sapply(train_test, RW, ACCURACY=accuracyFun),
          rwd = sapply(train_test, RWD, ACCURACY=accuracyFun),
          wn = sapply(train_test, WN, ACCURACY=accuracyFun),
          theta = sapply(train_test, THETA, ACCURACY=accuracyFun),
          stlar = sapply(train_test, STLAR, ACCURACY=accuracyFun),
          nn = sapply(train_test, NN, ACCURACY=accuracyFun),
          snaive = sapply(train_test, SNAIVE, ACCURACY=accuracyFun),
          mstl = sapply(train_test, MSTL, ACCURACY=accuracyFun),
          tbats = sapply(train_test, TBATS, ACCURACY=accuracyFun)
   )
 })

 return(list(accuracy=mat, ARIMA = arima_models, ETS =ets_models))

}
#'@examples
#'library(Mcomp)
#'tslist <- list(M3[[1]], M3[[2]])
#'fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "stlar", "nn", "snaive", "mstl"),database ="M3", cal_MASE, h=6)
