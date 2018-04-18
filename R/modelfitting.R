#' Calculate accuracy measure from different forecasting methods
#'
#' @param ts_info list containing training and test part of a time series
#' @param function_name function to calculate the accuracy function, the arguments of this function
#' should be forecast, training and test set of the time series
#' @return \code{accuracy_ets} returns a list which contains the accuracy and name of the specific ETS model.
#' \code{accuracy_arima} a list which contains the accuracy and name of the specific ARIMA model.
#' \code{accuracy_rw} returns accuracy measure calculated baded on random walk model
#' \code{accuracy_rwd} returns accuracy measure calculated baded on random walk with drift model
#' \code{accuracy_wn} returns accuracy measure calculated based on white noise model
#' \code{accuracy_theta} returns accuracy measure calculated based on theta method
#' \code{accuracy_stlar} returns accuracy measure calculated based on stlar method
#' \code{accuracy_nn} returns accuracy measure calculated based on neural network forecasts
#' \code{accuracy_snaive} returns accuracy measure calculated based on snaive method
#' \code{accuracy_mstl} returns accuracy measure calculated based on multiple seasonal decomposition
#' \code{accuracy_tbats} returns accuracy measure calculated based on TBATS models
#' @name accuracy_ets
NULL

#' @rdname accuracy_ets
accuracy_ets <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
ets_fit <- forecast::ets(training)
forecastETS <- forecast(ets_fit,h)$mean
ACCURACY <- match.fun(function_name)
ETSaccuracy <- ACCURACY(forecast=forecastETS,test=test, training=training)
ETSmodel <- as.character(ets_fit)
return(list(ETSmodel=ETSmodel, ETSaccuracy=ETSaccuracy))
}

#' @rdname accuracy_ets
accuracy_arima <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
arima_fit <- forecast::auto.arima(training)
forecastARIMA <- forecast(arima_fit,h)$mean
ACCURACY <- match.fun(function_name)
ARIMAaccuracy <- ACCURACY(forecast=forecastARIMA, test=test, training=training)
ARIMAmodel <- as.character(arima_fit)
return(list(ARIMAmodel=ARIMAmodel, ARIMAaccuracy=ARIMAaccuracy))
}

#' @rdname accuracy_ets
accuracy_rw <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
rw_fit <- forecast::rwf(training,drift=FALSE, h=h)
forecastRW <- forecast(rw_fit)$mean
ACCURACY <- match.fun(function_name)
RWaccuracy <- ACCURACY(forecast=forecastRW,test=test, training=training)
return(RWaccuracy)

}

#' @rdname accuracy_ets
accuracy_rwd <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
if (forecast::is.constant(training)==TRUE){return(NA)}
rwd_fit <- rwf(training,drift=TRUE, h=h)
forecastRWD <- forecast(rwd_fit)$mean
ACCURACY <- match.fun(function_name)
RWDaccuracy <- ACCURACY(forecast=forecastRWD, test=test, training=training)
return(RWDaccuracy)

}

#' @rdname accuracy_ets
accuracy_wn <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_WN <- forecast::auto.arima(training, d=0, D=0, max.p=0, max.q = 0,
                     max.Q=0, max.P = 0)
forecastWN <- forecast(fit_WN,h)$mean
ACCURACY <- match.fun(function_name)
WNaccuracy <- ACCURACY(forecast=forecastWN,test=test, training=training)
return(WNaccuracy)

}

#' @rdname accuracy_ets
accuracy_theta <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
m <- frequency(training)
ACCURACY <- match.fun(function_name)
if (m > 1){
  # using stheta method with seasonal adjustment
  # require(forecTheta)
  forecastTheta <- forecTheta::stheta(training,h=h, s='additive')$mean
  THETAaccuracy <- ACCURACY(forecast=forecastTheta, test=test, training=training)
} else {
  # using thetaf method
  forecastTheta <-forecast::thetaf(training,h=length(test))$mean
  THETAaccuracy <- ACCURACY(forecast=forecastTheta, test=test, training=training)
}
return(THETAaccuracy)
}

#' @rdname accuracy_ets
accuracy_stlar <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
forecastSTLAR <- stlar(training,h=h)$mean
ACCURACY <- match.fun(function_name)
STLARaccuracy <- ACCURACY(forecast=forecastSTLAR, test=test, training=training)
return(STLARaccuracy)
}

#' @rdname accuracy_ets
accuracy_nn <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_nnetar <- forecast::nnetar(training)
forecastnnetar <- forecast(fit_nnetar, h=h)$mean
ACCURACY <- match.fun(function_name)
nnetarACCURACY <- ACCURACY(forecast=forecastnnetar, test=test, training=training)
return(nnetarACCURACY)
}

#' @rdname accuracy_ets
accuracy_snaive <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
forecastSNAIVE <- forecast::snaive(training, h=length(test))$mean
ACCURACY <- match.fun(function_name)
SNAIVEaccuracy <- ACCURACY(forecast=forecastSNAIVE, test=test, training=training)
return(SNAIVEaccuracy)
}

#' @rdname accuracy_ets
accuracy_mstl <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_mstl <- forecast::mstl(training)
forecastMSTL <- forecast(training, h=length(test))$mean
ACCURACY <- match.fun(function_name)
MSTLaccuracy <- ACCURACY(forecast=forecastMSTL, test=test, training=training)
return(MSTLaccuracy)
}

#' @rdname accuracy_ets
accuracy_tbats <- function(ts_info, function_name){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fitTBAT <- forecast::tbats(training)
forecastTBATS <- forecast(fitTBAT, h=h)$mean
ACCURACY <- match.fun(function_name)
TBATSaccuracy <- ACCURACY(forecast=forecastTBATS, test=test, training=training)
return(TBATSaccuracy)
}
