#' identify the best forecasting method
#'
#' identify the best forecasting method according to the forecast accuacy measure
#' @param accuracy_mat matrix of forecast accuracy measures (rows: time series, columns: forecasting method)
#' @return a vector: best forecasting method for each series corresponding to the rows of accuracy_mat
#' @author Thiyanga Talagala
#' @export
classlabel <- function(accuracy_mat){

  df <- as.data.frame(accuracy_mat)
  name_col <- colnames(df)[apply(df,1,which.min)]
  return(name_col)
}
#'@examples
#' library(Mcomp)
#' tslist <- list(M3[[1]], M3[[2]])
#' accmat <- fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "stlar", "nn", "snaive", "mstl"),database ="M3", cal_MASE, h=6)
#' classlabel(accmat$accuracy)
