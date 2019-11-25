#' This function is call to be inside fforms_combination
#'
#' Given weights and time series in a two seperate vectors calculate combination forecast
#' @param x weights and names of models (output based on fforms.ensemble)
#' @param y time series values
#' @param h forecast horizon
#' @return list of combination forecasts corresponds to point, lower and upper
#' @author Thiyanga Talagala
#' @export
  combination_forecast_inside <- function(x, y, h){
    # x - list containing the forecast models and weight (ensemble)
    # y - list of time series (train_test)

    training <- y$training
    test <-  y$test
    if(is.na(h) == TRUE){
    h <- length(test)}
    m <- frequency(training)

    predictions <- names(x) ## model names
    length.x <- length(x)

    fcast <- list()
    forecast_mean <- matrix(NA, ncol=h, nrow = length.x)
    forecast_lower <- matrix(NA, ncol=h, nrow = length.x)
    forecast_upper <- matrix(NA, ncol=h, nrow = length.x)

    for (i in 1:length.x){

      if (predictions[i] == "ARIMA") {
        fcast[[i]] <- tryCatch({
          fit_arima <- auto.arima(training, seasonal = FALSE)
          forecast(fit_arima,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))})

      } else if (predictions[i] == "ARMA/AR/MA") {
        fcast[[i]] <-  tryCatch({
          fit_arma <- auto.arima(training,d=0, stationary=TRUE, seasonal = FALSE)
          forecast(fit_arma,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      }else if (predictions[i] == "SARIMA") {
        fcast[[i]] <- tryCatch({
          fit_sarima <- auto.arima(training, seasonal=TRUE)
          forecast(fit_sarima,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      }  else if (predictions[i] == "ETS-dampedtrend") {
        fcast[[i]] <- tryCatch({
          fit_ets <- ets(training, model= "ZZN", damped = TRUE)
          forecast(fit_ets,h, level=c(95))
          }, error=function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "ETS-notrendnoseasonal") {
        fcast[[i]] <-  tryCatch({
          fit_ets <- ets(training, model= "ZNN", damped = FALSE)
          forecast(fit_ets,h, level=c(95))
          }, error=function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "ETS-trend") {
        fcast[[i]] <- tryCatch({
          fit_ets <- ets(training, model= "ZZN", damped = FALSE)
          forecast(fit_ets,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "ETS-trendseasonal") {
        fcast[[i]] <- tryCatch({
          fit_ets <- ets(training, model= "ZZZ", damped = FALSE)
          forecast(fit_ets,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      }else if (predictions[i] == "ETS-dampedtrendseasonal") {
        fcast[[i]] <- tryCatch({
          fit_ets <- ets(training, model= "ZZZ", damped = TRUE)
          forecast(fit_ets,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      }else if (predictions[i] == "ETS-seasonal") {
        fcast[[i]] <- tryCatch({
          fit_ets <- ets(training, model= "ZNZ")
          forecast(fit_ets,h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      }else if (predictions[i] == "snaive") {
        fcast[[i]] <- tryCatch({
          snaive(training, h=h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
           })

      }else if (predictions[i] == "rw") {
        fcast[[i]] <- tryCatch({
          rwf(training, drift = FALSE, h=h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "rwd") {
        fcast[[i]] <- tryCatch({
          rwf(training, drift = TRUE, h=h, level=c(95))
          }, error = function(e){
          rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "stlar") {
        fcast[[i]] <- tryCatch({
            if(frequency(training)==1 | length(training) <= 2*frequency(training)){
            forecast(auto.arima(training, max.q=0), h=h, level=c(95))
            } else {
            fit_stlm <- stlm(training, modelfunction=ar)
            forecast(fit_stlm, h=h, level=c(95))
            }
          }, error = function(e){
            rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "theta") {
        fcast[[i]] <- tryCatch({
                if (m > 1){
                # using stheta method with seasonal adjustment
                # require(forecTheta)
                fitTheta <- forecTheta::stm(training,h=h,  s='additive', level=c(80, 90, 95))
                list(mean=fitTheta$mean, lower = fitTheta$lower[,3], upper = fitTheta$upper[,3])
                }else{
                # using thetaf method
                forecast::thetaf(training,h=h, level=c(95))
                }
             }, error = function(e){
                rwf(training, drift = FALSE, h=h, level=c(95))
             })

      } else if (predictions[i] == "nn"){
        fcast[[i]] <- tryCatch({
              fit_nnetar <- forecast::nnetar(training)
              forecast(fit_nnetar, PI=TRUE, h=h, level=c(95))
          }, error = function(e){
              rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "mstl"| predictions[i] == "mstlets"){
          fcast[[i]] <- tryCatch({
            fit_mstl <- stlf(training, level=c(95))
            forecast(fit_mstl, h=h)
          }, error = function(e){
            rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "mstlarima"){
        fcast[[i]] <- tryCatch({
              fit_mstl <- stlf(training, method="arima", level=c(95))
             forecast(fit_mstl, h=h)
          }, error = function(e){
            rwf(training, drift = FALSE, h=h, level=c(95))
          })

      } else if (predictions[i] == "tbats"){
        fcast[[i]] <- tryCatch({
            fit_tbats <- forecast::tbats(training)
            forecast(fit_tbats, h=h, level=c(95))
            }, error = function(e){
            rwf(training, drift = FALSE, h=h, level=c(95))
            })

      } else {
        fcast[[i]] <-  tryCatch({
            fit_wn <- Arima(training,order=c(0,0,0))
            forecast(fit_wn,h, level=c(95))
            }, error = function(e){
            rwf(training, drift = FALSE, h=h, level=c(95))
          })
      }
      forecast_mean[i,] <- as.vector(fcast[[i]]$mean)
      forecast_lower[i,] <- as.vector(fcast[[i]]$lower)
      forecast_upper[i,] <- as.vector(fcast[[i]]$upper)

    }
    #normalize.weights <- x/sum(x)
    weights <- matrix(x, ncol=length.x)
    weightedmean <- weights %*% forecast_mean
    weightedlower <- weights %*% forecast_lower
    weightedupper <- weights %*% forecast_upper

    forecast_results <- list(mean = weightedmean, lower=weightedlower, upper=weightedupper)
    forecast_results
  }



