#' scale MASE and sMAPE by median
#'
#' Given a matrix of MASE and sMAPE for each forecasting method and scaled by median and take the mean of
#' MASE-scaled by median and sMAPE-scaled by median as the forecast accuracy measure to identify the class labels
#'
#'@param x output form the function fcast_accuracy, where the parameter accuracyFun = cal_m4measures
#'@return a list with accuracy matrix, vector of arima models and vector of ets models the accuracy
#'for each forecast-method is average of scaled-MASE and scaled-sMAPE. Median of MASE and sMAPE calculated
#'based on forecast produced from different models for a given series.
#'@export
cal_medianscaled <- function(x){

  accuracy_mat <- x$accuracy
  mat_devidebymedian <- t(apply(accuracy_mat, 1, function(x) x/median(x, na.rm=TRUE)))
  accuracy_scaled <- rowsum(mat_devidebymedian, group = as.integer(gl(nrow(mat_devidebymedian),2,
                                                                      nrow(mat_devidebymedian))))
  accuracy <- accuracy_scaled/2
  ETS <- x$ETS
  ARIMA <- x$ARIMA

  accuracy_list <- list(accuracy=accuracy, ETS=ETS, ARIMA=ARIMA)

}

