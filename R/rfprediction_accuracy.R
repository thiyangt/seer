#' function to calculate forecast-accuracy for new series
#'
#' Given the prediction results of random forest calculate the
#' forecast-accuracy for the test set
#' @param predictions prediction results obtained from  random forest classifier
#' @param tslist list of new time series
#' @param database whethe the time series is from mcom or other
#' @param  function_name to calculate accuracy measure, the arguments for the
#' accuracy function should be training period, test period and forecast
#' @param h length of the forecast horizon
#' @return a numeric vector contains the forecast accuracy for each series
#' @export
rfprediction_accuracy <- function(predictions, tslist, database, function_name, h){

  if (database == "other") {
    train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  total_ts <- length(train_test)
  accuracy_value <- numeric(total_ts)

  accuracyFun <- match.fun(function_name)

  for (i in 1:total_ts){

    training <- train_test[[i]]$training
    test <-  train_test[[i]]$test

    m <- frequency(training)
    if (predictions[i] == "ARIMA") {
      fit_arima <- auto.arima(training, seasonal = FALSE)
      forecast_arima <- forecast(fit_arima,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_arima, training=training, test=test)

    } else if (predictions[i] == "ARMA/AR/MA") {
      fit_arma <- auto.arima(training,d=0, stationary=TRUE, seasonal = FALSE)
      forecast_arma <- forecast(fit_arma,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_arma, training=training, test=test)

    }else if (predictions[i] == "SARIMA") {
      fit_sarima <- auto.arima(training, seasonal=TRUE)
      forecast_sarima <- forecast(fit_sarima,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_sarima, training=training, test=test)

    }  else if (predictions[i] == "ETS-dampedtrend") {
      fit_ets <- ets(training, model= "ZZN", damped = TRUE)
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "ETS-notrendnoseasonal") {
      fit_ets <- ets(training, model= "ZNN", damped = FALSE)
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "ETS-trend") {
      fit_ets <- ets(training, model= "ZZN", damped = FALSE)
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "ETS-trendseasonal") {
      fit_ets <- ets(training, model= "ZZZ", damped = FALSE)
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    }else if (predictions[i] == "ETS-dampedtrendseasonal") {
      fit_ets <- ets(training, model= "ZZZ", damped = TRUE)
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    }else if (predictions[i] == "ETS-seasonal") {
      fit_ets <- ets(training, model= "ZNZ")
      forecast_ets <- forecast(fit_ets,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    }else if (predictions[i] == "snaive") {
      fit_snaive <- snaive(training, h=h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    }else if (predictions[i] == "rw") {
      fit_rw <- rwf(training, drift = FALSE)
      forecast_rw <- forecast(fit_rw,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "rwd") {
      fit_rwd <- rwf(training, drift = TRUE)
      forecast_rwd <- forecast(fit_rwd,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "stlar") {
      STLAR <- stlar(training,h=h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    } else if (predictions[i] == "theta") {
      if (m > 1){
        # using stheta method with seasonal adjustment
        # require(forecTheta)
        fitTheta <- forecTheta::stheta(training,h=h, s='additive')$mean
        accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)
      }else{
        # using thetaf method
        fitTheta <-forecast::thetaf(training,h=length(test))$mean
        accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)
      }
    } else if (predictions[i] == "nn"){
      fit_nnetar <- forecast::nnetar(training)
      forecast_nn <- forecast(fit_nnetar, h=h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_nn, training=training, test=test)

    } else if (predictions[i] == "mstl"){
      fit_mstl <- forecast::mstl(training)
      forecast_mstl <- forecast(fit_mstl, h=h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_mstl, training=training, test=test)

    } else if (predictions[i] == "tbats"){
      fit_tbats <- forecast::tbats(training)
      forecast_tbats <- forecast(fit_tbats, h=h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_tbats, training=training, test=test)

    } else {
      fit_wn <- Arima(training,order=c(0,0,0))
      forecast_wn <- forecast(fit_wn,h)$mean
      accuracy_value[i] <- accuracyFun(forecast=forecast_ets, training=training, test=test)

    }

  }

  return(accuracy_value)

}
