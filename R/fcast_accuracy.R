#' calculate forecast accuracy from different forecasting methods
#'
#' Calculate forecast accuracy on test set according to a specified criterion
#' @param tslist a list of time series
#' @param models a vector of models to compute
#' @param database whether the time series is from mcomp or other
#' @param accuracyFun function to calculate the accuracy measure, the arguments
#' for the accuracy function should be training, test and forecast
#' @param h forecast horizon
#' @param length_out number of measures calculated by a single function
#' @return a list with accuracy matrix, vector of arima models and vector of ets models
#' @author Thiyanga Talagala
#' @export
fcast_accuracy <- function(tslist, models = c("ets", "arima", "rw", "rwd", "wn",
                                         "theta", "stlar", "nn", "snaive", "mstlarima","mstlets", "tbats"), database
                           , accuracyFun, h, length_out){

  arima_models <- NA
  ets_models <- NA

  if (database == "other") {
   train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
   train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  if ("arima"%in% models) {
    arima_cal <- lapply(train_test, accuracy_arima, function_name=accuracyFun)
    arima_models <- sapply(arima_cal, function(temp){temp$ARIMAmodel})
  }

  if ("ets"%in% models) {
    ets_cal <- lapply(train_test, accuracy_ets, function_name=accuracyFun)
    ets_models <- sapply(ets_cal, function(temp){temp$ETSmodel})
  }


 mat <- sapply(models, function(f){

   switch(f,
          arima = sapply(arima_cal, function(temp){temp$ARIMAaccuracy}),
          ets = sapply(ets_cal, function(temp){temp$ETSaccuracy}),
          rw = sapply(train_test, accuracy_rw, function_name=accuracyFun),
          rwd = sapply(train_test, accuracy_rwd, function_name=accuracyFun, length_out=length_out),
          wn = sapply(train_test, accuracy_wn, function_name=accuracyFun, length_out=length_out),
          theta = sapply(train_test, accuracy_theta, function_name=accuracyFun, length_out=length_out),
          stlar = sapply(train_test, accuracy_stlar, function_name=accuracyFun, length_out=length_out),
          nn = sapply(train_test, accuracy_nn, function_name=accuracyFun, length_out=length_out),
          snaive = sapply(train_test, accuracy_snaive, function_name=accuracyFun, length_out=length_out),
          mstlets = sapply(train_test, accuracy_mstl, function_name=accuracyFun, length_out=length_out, method="ets"),
          mstlarima = sapply(train_test, accuracy_mstl, function_name=accuracyFun, length_out=length_out, method="arima"),
          tbats = sapply(train_test, accuracy_tbats, function_name=accuracyFun, length_out=length_out)
   )
 })

 return(list(accuracy=mat, ARIMA = arima_models, ETS =ets_models))

}
#'@examples
#'library(Mcomp)
#'tslist <- list(M3[[1]], M3[[2]])
#'fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "stlar", "nn", "snaive", "mstl"),database ="M3", cal_MASE, h=6)
