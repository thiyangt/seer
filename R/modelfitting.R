# class labels

# ETS
ETS <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
ets_fit <- ets(training)
forecastETS <- forecast(ets_fit,h)$mean
ETSaccuracy <- ACCURACY(forecast=forecastETS,test=test, training=training)
ETSmodel <- as.character(ets_fit)
return(list(ETSmodel=ETSmodel, ETSaccuracy=ETSaccuracy))
}


# ARIMA
ARIMA <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
arima_fit <- auto.arima(training)
forecastARIMA <- forecast(arima_fit,h)$mean
ARIMAaccuracy <- ACCURACY(forecast=forecastARIMA, test=test, training=training)
ARIMAmodel <- as.character(arima_fit)
return(list(ARIMAmodel=ARIMAmodel, ARIMAaccuracy=ARIMAaccuracy))
}


# Random Walk
RW <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
rw_fit <- rwf(training,drift=FALSE, h=h)
forecastRW <- forecast(rw_fit)$mean
RWaccuracy <- ACCURACY(forecast=forecastRW,test=test, training=training)
return(RWaccuracy)

}

#Random walk with drift

RWD <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
if (sd(training)==0){return(NA)}
rwd_fit <- rwf(training,drift=TRUE, h=h)
forecastRWD <- forecast(rwd_fit)$mean
RWDaccuracy <- ACCURACY(forecast=forecastRWD, test=test, training=training)
return(RWDaccuracy)

}

# White noise process

WN <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_WN <- auto.arima(training, d=0, D=0, max.p=0, max.q = 0,
                     max.Q=0, max.P = 0)
forecastWN <- forecast(fit_WN,h)$mean
WNaccuracy <- ACCURACY(forecast=forecastWN,test=test, training=training)
return(WNaccuracy)

}

# Theta Method
THETA <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
m <- frequency(training)
if (m > 1){
  # using stheta method with seasonal adjustment
  # require(forecTheta)
  forecastTheta <- forecTheta::stheta(training,h=h, s='additive')$mean
  THETAaccuracy <- ACCUARACY(forecast=forecastTheta, test=test, training=training)
} else {
  # using thetaf method
  forecastTheta <-forecast::thetaf(training,h=length(test))$mean
  THETAaccuracy <- ACCURACY(forecast=forecastTheta, test=test, training=training)
}
return(THETAaccuracy)
}

# STL-AR

STLAR <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
forecastSTLAR <- stlar(training,h=h)$mean
STLARaccuracy <- ACCURACY(forecast=forecastSTLAR, test=test, training=training)
return(STLARaccuracy)
}

# Neural Network Time Series Forecasts
NN <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_nnetar <- nnetar(training)
forecastnnetar <- forecast(fit_nnetar, h=h)$mean
nnetarACCURACY <- ACCURACY(forecast=forecastnnetar, test=test, training=training)
return(nnetarACCURACY)
}


# season naive method
SNAIVE <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
forecastSNAIVE <- snaive(training, h=length(test))$mean
SNAIVEaccuracy <- ACCURACY(forecast=forecastSNAIVE, test=test, training=training)
return(SNAIVEaccuracy)
}


# mstl
MSTL <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fit_mstl <- mstl(training)
forecastMSTL <- forecast(training, h=length(test))$mean
MSTLaccuracy <- ACCURACY(forecast=forecastMSTL, test=test, training=training)
return(MSTLaccuracy)
}

# TBATS

TBATS <- function(ts_info, ACCURACY){
training <- ts_info$training
test <- ts_info$test
h <- length(test)
fitTBAT <- tbats(training)
forecastTBATS <- forecast(fitTBAT, h=h)$mean
TBATSaccuracy <- ACCURACY(forecast=forecastTBATS, test=test, training=training)
return(TBATSaccuracy)
}
