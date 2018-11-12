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
#' @param fcast_save if the argument is TRUE, forecasts from each series are saved
#' @return a list with accuracy matrix, vector of arima models and vector of ets models
#' @author Thiyanga Talagala
#' @export
fcast_accuracy <- function(tslist, models = c("ets", "arima", "rw", "rwd", "wn",
                                         "theta", "stlar", "nn", "snaive", "mstlarima","mstlets", "tbats"), database
                           , accuracyFun, h, length_out, fcast_save){

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

  if ("rw" %in% models){
    rw_cal <- lapply(train_test, accuracy_rw, function_name=accuracyFun)
  }

  if ("rwd" %in% models){
    rwd_cal <- lapply(train_test, accuracy_rwd, function_name=accuracyFun, length_out=length_out)
  }

  if ("wn" %in% models){
    wn_cal <- lapply(train_test, accuracy_wn, function_name=accuracyFun, length_out=length_out)
  }

  if ("theta" %in% models){
    theta_cal <- lapply(train_test, accuracy_theta, function_name=accuracyFun, length_out=length_out)
  }

  if ("stlar" %in% models){
    stlar_cal <- lapply(train_test, accuracy_stlar, function_name=accuracyFun, length_out=length_out)
  }

  if("nn" %in% models){
    nn_cal <- lapply(train_test, accuracy_nn, function_name=accuracyFun, length_out=length_out)
  }

  if("snaive" %in% models){
    snaive_cal <- lapply(train_test, accuracy_snaive, function_name=accuracyFun, length_out=length_out)
  }

  if("mstlets" %in% models){
    mstlets_cal <- lapply(train_test, accuracy_mstl, function_name=accuracyFun, length_out=length_out, mtd="ets")
  }

  if("mstlarima" %in% models){
    mstlarima_cal <- lapply(train_test, accuracy_mstl, function_name=accuracyFun, length_out=length_out, mtd="arima")
  }

  if("tbats" %in% models){
    tbats_cal <- lapply(train_test, accuracy_tbats, function_name=accuracyFun, length_out=length_out)
  }


 mat <- sapply(models, function(f){

   switch(f,
          arima = sapply(arima_cal, function(temp){temp$ARIMAaccuracy}),
          ets = sapply(ets_cal, function(temp){temp$ETSaccuracy}),
          rw = sapply(rw_cal, function(temp){temp$RWaccuracy}),
          rwd = sapply(rwd_cal, function(temp){temp$RWDaccuracy}),
          wn = sapply(wn_cal, function(temp){temp$WNaccuracy}),
          theta = sapply(theta_cal, function(temp){temp$THETAaccuracy}),
          stlar = sapply(stlar_cal, function(temp){temp$STLARaccuracy}),
          nn = sapply(nn_cal, function(temp){temp$nnetarACCURACY}),
          snaive = sapply(snaive_cal, function(temp){temp$SNAIVEaccuracy}),
          mstlets = sapply(mstlets_cal, function(temp){temp$MSTLaccuracy}),
          mstlarima = sapply(mstlarima_cal, function(temp){temp$MSTLaccuracy}),
          tbats = sapply(tbats_cal, function(temp){temp$TBATSaccuracy})
   )
 })

 if (fcast_save==TRUE){

   fcast <- lapply(models, function(f){

     switch(f,
            arima = sapply(arima_cal, function(temp){temp$ARIMAfcast}),
            ets = sapply(ets_cal, function(temp){temp$ETSfcast}),
            rw = sapply(rw_cal, function(temp){temp$rwfcast}),
            rwd = sapply(rwd_cal, function(temp){temp$rwdfcast}),
            wn = sapply(wn_cal, function(temp){temp$wnfcast}),
            theta = sapply(theta_cal, function(temp){temp$thetafcast}),
            stlar = sapply(stlar_cal, function(temp){temp$STLARfcast}),
            nn = sapply(nn_cal, function(temp){temp$nnfcast}),
            snaive = sapply(snaive_cal, function(temp){temp$SNAIVEfcast}),
            mstlets = sapply(mstlets_cal, function(temp){temp$MSTLfcast}),
            mstlarima = sapply(mstlarima_cal, function(temp){temp$MSTLfcast}),
            tbats = sapply(tbats_cal, function(temp){temp$TBATSfcast})
     )
   })
   names(fcast) = models
return(list(accuracy=mat, ARIMA = arima_models, ETS =ets_models, forecasts = fcast))

 }

 return(list(accuracy=mat, ARIMA = arima_models, ETS =ets_models))

}
#'@examples
#'library(Mcomp)
#'tslist <- list(M3[[1]], M3[[2]])
#'fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "stlar", "nn"),database ="M3", cal_MASE, h=6, length_out=1, fcast_save=TRUE)
