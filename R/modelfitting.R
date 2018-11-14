#' Forecast-accuracy calculation
#'
#' Calculate accuracy measure based on ETS models
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return a list which contains the accuracy and name of the specific ETS model.
#' @export
accuracy_ets <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
ets_fit <- forecast::ets(training)
forecastETS <- forecast(ets_fit,h)$mean
ACCURACY <- match.fun(function_name)
ETSaccuracy <- ACCURACY(forecast=forecastETS,test=test, training=training)
ETSmodel <- as.character(ets_fit)
return(list(ETSmodel=ETSmodel, ETSaccuracy=ETSaccuracy, ETSfcast=forecastETS))
}, error=function(e){return(list(ETSaccuracy=rep(NA, length_out), ETSmodel=ETSmodel, ETSfcast=forecastETS))})
}

#' Calculate accuracy measue based on ARIMA models
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return a list which contains the accuracy and name of the specific ARIMA model.
#' @export
accuracy_arima <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
arima_fit <- forecast::auto.arima(training)
forecastARIMA <- forecast(arima_fit,h)$mean
ACCURACY <- match.fun(function_name)
ARIMAaccuracy <- ACCURACY(forecast=forecastARIMA, test=test, training=training)
ARIMAmodel <- as.character(arima_fit)
return(list(ARIMAmodel=ARIMAmodel, ARIMAaccuracy=ARIMAaccuracy, ARIMAfcast=forecastARIMA))
}, error=function(e){return(list(ARIMAaccuracy=rep(NA, length_out), ARIMAfcast=forecastARIMA, ARIMAmodel=ARIMAmodel))})
}

#' Calculate accuracy measure based on random walk models
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return returns accuracy measure calculated baded on random walk model
#' @export
accuracy_rw <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
rw_fit <- forecast::rwf(training,drift=FALSE, h=h)
forecastRW <- forecast(rw_fit)$mean
ACCURACY <- match.fun(function_name)
RWaccuracy <- ACCURACY(forecast=forecastRW,test=test, training=training)
return(list(RWaccuracy=RWaccuracy, rwfcast=forecastRW))
}, error=function(e){return(list(RWaccuracy=rep(NA, length_out), rwfcast=forecastRW))})

}

#' Calculate accuracy measure based on random walk with drift
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return accuracy measure calculated baded on random walk with drift model
#' @export
accuracy_rwd <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
if (forecast::is.constant(training)==TRUE){return(NA)}
tryCatch({
rwd_fit <- rwf(training,drift=TRUE, h=h)
forecastRWD <- forecast(rwd_fit)$mean
ACCURACY <- match.fun(function_name)
RWDaccuracy <- ACCURACY(forecast=forecastRWD, test=test, training=training)
return(list(RWDaccuracy=RWDaccuracy, rwdfcast=forecastRWD))
}, error=function(e){return(list(RWDaccuracy=rep(NA, length_out), rwdfcast=forecastRWD))})
}

#' Calculate accuracy measure based on white noise process
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return returns accuracy measure calculated based on white noise process
#' @export
accuracy_wn <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
fit_WN <- forecast::auto.arima(training, d=0, D=0, max.p=0, max.q = 0,
                     max.Q=0, max.P = 0)
forecastWN <- forecast(fit_WN,h)$mean
ACCURACY <- match.fun(function_name)
WNaccuracy <- ACCURACY(forecast=forecastWN,test=test, training=training)
return(list(WNaccuracy=WNaccuracy, wnfcast=forecastWN))
}, error=function(e){return(list(WNaccuracy=rep(NA, length_out), wnfcast=forecastWN))})
}

#' Calculate accuracy measure based on Theta method
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return returns accuracy measure calculated based on theta method
#' @export
accuracy_theta <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
m <- frequency(training)
ACCURACY <- match.fun(function_name)
tryCatch({
if (m > 1){
  # using stheta method with seasonal adjustment
  # require(forecTheta)
  tryCatch({
    forecastTheta <- forecTheta::stheta(training,h=h, s='additive')$mean
  }, error=function(e){return(list(THETAaccuracy=rep(NA, length_out), thetafcast=rep(NA, h)))})
  tryCatch({
    THETAaccuracy <- ACCURACY(forecast=forecastTheta, test=test, training=training)
  }, error=function(e){return(list(THETAaccuracy=rep(NA, length_out), thetafcast=rep(NA, h)))})
} else {
  # using thetaf method
  forecastTheta <-forecast::thetaf(training,h=length(test))$mean
  THETAaccuracy <- ACCURACY(forecast=forecastTheta, test=test, training=training)
}
return(list(THETAaccuracy=THETAaccuracy, thetafcast=forecastTheta))
}, error=function(e){return(list(THETAaccuracy=rep(NA, length_out), thetafcast=rep(NA, h)))})
}

#' Calculate accuracy measure based on STL-AR method
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return accuracy measure calculated based on stlar method
#' @export
accuracy_stlar <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
forecastSTLAR <- stlar(training,h=h)$mean
ACCURACY <- match.fun(function_name)
tryCatch({
STLARaccuracy <- ACCURACY(forecast=forecastSTLAR, test=test, training=training)
return(list(STLARaccuracy=STLARaccuracy, STLARfcast=forecastSTLAR))
}, error=function(e){return(list(STLARaccuracy=rep(NA, length_out), STLARfcast=forecastSTLAR))})
}

#' Calculate accuracy measure calculated based on neural network forecasts
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return accuracy measure calculated based on neural network forecasts
#' @export
accuracy_nn <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
fit_nnetar <- forecast::nnetar(training)
forecastnnetar <- forecast(fit_nnetar, h=h)$mean
ACCURACY <- match.fun(function_name)
nnetarACCURACY <- ACCURACY(forecast=forecastnnetar, test=test, training=training)
return(list(nnetarACCURACY=nnetarACCURACY, nnfcast=forecastnnetar))
}, error=function(e){return(list(nnetarACCURACY=rep(NA, length_out), nnfcast=forecastnnetar))})
}

#' Calculate accuracy measure based on snaive method
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return accuracy measure calculated based on snaive method
#' @export
accuracy_snaive <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
forecastSNAIVE <- forecast::snaive(training, h=length(test))$mean
ACCURACY <- match.fun(function_name)
SNAIVEaccuracy <- ACCURACY(forecast=forecastSNAIVE, test=test, training=training)
return(list(SNAIVEaccuracy=SNAIVEaccuracy, SNAIVEfcast=forecastSNAIVE))
}, error=function(e){return(list(SNAIVEaccuracy=rep(NA, length_out), SNAIVEfcast=forecastSNAIVE))})
}

#' Calculate accuracy based on MSTL
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @param mtd Method to use for forecasting the seasonally adjusted series
#' @return accuracy measure calculated based on multiple seasonal decomposition
#' @export
accuracy_mstl <- function(ts_info, function_name, length_out, mtd){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
tryCatch({
fit_stlf <- forecast::stlf(training, method=mtd)
forecastMSTL <- forecast(fit_stlf, h=length(test))$mean
ACCURACY <- match.fun(function_name)
MSTLaccuracy <- ACCURACY(forecast=forecastMSTL, test=test, training=training)
return(list(MSTLaccuracy=MSTLaccuracy, MSTLfcast=forecastMSTL))
}, error=function(e){return(list(MSTLaccuracy=rep(NA, length_out), MSTLfcast=forecastMSTL))})
}

#' Calculate accuracy measure based on TBATS
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @param length_out number of measures calculated by the function
#' @return accuracy measure calculated based on TBATS models
#' @export
accuracy_tbats <- function(ts_info, function_name, length_out){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
ACCURACY <- match.fun(function_name)
tryCatch({
fitTBAT <- forecast::tbats(training)
forecastTBATS <- forecast(fitTBAT, h=h)$mean
TBATSaccuracy <- ACCURACY(forecast=forecastTBATS, test=test, training=training)
return(list(TBATSaccuracy=TBATSaccuracy, TBATSfcast=forecastTBATS))
}, error=function(e){return(list(TBATSaccuracy=rep(NA, length_out), TBATSfcast=forecastTBATS))})
}
