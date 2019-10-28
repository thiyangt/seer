#' function to calculate point forecast, 95\% confidence intervals, forecast-accuracy for new series
#'
#' Given the prediction results of random forest calculate point forecast, 95\% confidence intervals,
#' forecast-accuracy for the test set
#'
#' @param predictions prediction results obtained from  random forest classifier
#' @param tslist list of new time series
#' @param database whethe the time series is from mcom or other
#' @param accuracy if true a accuaracy measure will be calculated
#' @param  function_name to calculate accuracy measure, the arguments for the
#' accuracy function should be training period, test period and forecast
#' @param h length of the forecast horizon
#' @return a list containing, point forecast, confidence interval, accuracy measure
#' @export
rf_forecast <- function(predictions, tslist, database, function_name, h, accuracy){

  if (database == "other") {
    train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  total_ts <- length(train_test)
  accuracy_value <- numeric(total_ts)
  forecast_mean <- matrix(NA, nrow=total_ts, ncol=h)
  forecast_lower <- matrix(NA, nrow=total_ts, ncol=h)
  forecast_upper <- matrix(NA, nrow=total_ts, ncol=h)

  accuracyFun <- match.fun(function_name)

  for (i in 1:total_ts){

    training <- train_test[[i]]$training
    test <-  train_test[[i]]$test

    m <- frequency(training)
    if (predictions[i] == "ARIMA") {
      fit_arima <- auto.arima(training, seasonal = FALSE)
      fcast <- forecast(fit_arima,h, level=c(95))

    } else if (predictions[i] == "ARMA/AR/MA") {
      fit_arma <- auto.arima(training,d=0, stationary=TRUE, seasonal = FALSE)
      fcast <- forecast(fit_arma,h, level=c(95))

    }else if (predictions[i] == "SARIMA") {
      fit_sarima <- auto.arima(training, seasonal=TRUE)
      fcast <- forecast(fit_sarima,h, level=c(95))

    }  else if (predictions[i] == "ETS-dampedtrend") {
      fit_ets <- ets(training, model= "ZZN", damped = TRUE)
      fcast <- forecast(fit_ets,h, level=c(95))

    } else if (predictions[i] == "ETS-notrendnoseasonal") {
      fit_ets <- ets(training, model= "ZNN", damped = FALSE)
      fcast <- forecast(fit_ets,h, level=c(95))

    } else if (predictions[i] == "ETS-trend") {
      fit_ets <- ets(training, model= "ZZN", damped = FALSE)
      fcast <- forecast(fit_ets,h, level=c(95))

    } else if (predictions[i] == "ETS-trendseasonal") {
      fit_ets <- ets(training, model= "ZZZ", damped = FALSE)
      fcast <- forecast(fit_ets,h, level=c(95))

    }else if (predictions[i] == "ETS-dampedtrendseasonal") {
      fit_ets <- ets(training, model= "ZZZ", damped = TRUE)
      fcast <- forecast(fit_ets,h, level=c(95))

    }else if (predictions[i] == "ETS-seasonal") {
      fit_ets <- ets(training, model= "ZNZ")
      fcast <- forecast(fit_ets,h, level=c(95))

    }else if (predictions[i] == "snaive") {
      fcast <- snaive(training, h=h, level=c(95))

    }else if (predictions[i] == "rw") {
      fcast <- rwf(training, drift = FALSE, h=h, level=c(95))

    } else if (predictions[i] == "rwd") {
      fcast <- rwf(training, drift = TRUE, h=h, level=c(95))

    } else if (predictions[i] == "stlar") {

      if(frequency(training)==1 | length(training) <= 2*frequency(training)){
        fcast <- forecast(auto.arima(training, max.q=0), h=h, level=c(95))
      } else {
        fit_stlm <- stlm(training, modelfunction=ar)
        fcast <- forecast(fit_stlm, h=h, level=c(95))
      }

    } else if (predictions[i] == "theta") {
      if (m > 1){
        # using stheta method with seasonal adjustment
        # require(forecTheta)
        fitTheta <- forecTheta::stm(training,h=h,  s='additive', level=c(80, 90, 95))
        fcast <- list(mean=fitTheta$mean, lower = fitTheta$lower[,3], upper = fitTheta$upper[,3])
      }else{
        # using thetaf method
        fcast <-forecast::thetaf(training,h=h, level=c(95))
      }
    } else if (predictions[i] == "nn"){
      fit_nnetar <- forecast::nnetar(training)
      fcast <- forecast(fit_nnetar, PI=TRUE, h=h, level=c(95))

    } else if (predictions[i] == "mstl"| predictions[i] == "mstlets"){
      # if(frequency(training)==1 | length(training) <= 2*frequency(training)){
      #   fit_ets <- ets(training)
      #   fcast <- forecast(fit_ets,h, level=c(95))
      # } else {
      fit_mstl <- stlf(training, level=c(95))
      fcast <- forecast(fit_mstl, h=h)
      #  }

    } else if (predictions[i] == "mstlarima"){
      # if(frequency(training)==1 | length(training) <= 2*frequency(training)){
      #    fit_ets <- ets(training)
      #   fcast <- forecast(fit_ets,h, level=c(95))
      #  } else {
      fit_mstl <- stlf(training, method="arima", level=c(95))
      fcast <- forecast(fit_mstl, h=h)
      #  }

    } else if (predictions[i] == "tbats"){
      fit_tbats <- forecast::tbats(training)
      fcast <- forecast(fit_tbats, h=h, level=c(95))

    } else {
      fit_wn <- Arima(training,order=c(0,0,0))
      fcast <- forecast(fit_wn,h, level=c(95))
    }

    forecast_mean[i,] <- as.vector(fcast$mean)
    forecast_lower[i,] <- as.vector(fcast$lower)
    forecast_upper[i,] <- as.vector(fcast$upper)

    if(accuracy==TRUE){
      accuracy_value[i] <- accuracyFun(forecast=fcast$mean, training=training, test=test)
    }

  }

  forecast_results <- list(mean = forecast_mean, lower=forecast_lower, upper=forecast_upper, accuracy=accuracy_value)
  return(forecast_results)

}
