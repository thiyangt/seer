#' Classify labels according to the FFORMS famework
#'
#' This function further classify class labels as in FFORMS framework
#' @param bestmethod a vector: names of best forecasting methods
#' @param df_final a dataframe: output from split_names function
#' @return a vector of class labels in FFORMS framewok
#' @export
classify_labels <- function(df_final, bestmethod){

  length_df <- dim(df_final)[1]
  classlabel <- as.character(length_df)

for(i in 1:length_df){

  if (df_final[i, "Model"] == "ARIMA") {
    ar_coef <- as.numeric(as.character(df_final[i, "p"]))
    num_diff <- as.numeric(as.character(df_final[i, "d"]))
    ma_coef <- as.numeric(as.character(df_final[i, "q"]))
    arma <- sum(ar_coef, ma_coef)
    drift <- as.numeric(df_final[i, "outcome_with_drift"] == 1)
    if (arma!=0 & num_diff== 0){
      classlabel[i] <- "ARMA/AR/MA"
    } else
      classlabel[i] <- "ARIMA"

  } else if(df_final[i, "Model"] == "ETS"){
    error <- as.character(df_final[i, "p"])
    trend <- as.character(df_final[i, "d"])
    seasonality <- as.character(df_final[i, "q"])

    if(error== "A" & trend== "A" & seasonality== "A") {
      classlabel[i] <- "ETS-trendseasonal"
    } else if (error== "A" & trend== "A" & seasonality== "N") {
      classlabel[i] <- "ETS-trend"
    } else if (error== "A" & trend== "Ad" & seasonality== "A"){
      classlabel[i] <- "ETS-dampedtrendseasonal"
    }else if (error== "A" & trend== "Ad" & seasonality== "N"){
      classlabel[i] <- "ETS-dampedtrend"
    }else if (error== "A" & trend== "N" & seasonality== "A"){
      classlabel[i] <- "ETS-seasonal"
    } else if (error== "A" & trend== "N" & seasonality== "N"){
      classlabel[i] <- "ETS-notrendnoseasonal"
    }else if (error== "M" & trend== "A" & seasonality== "A"){
      classlabel[i] <- "ETS-trendseasonal"
    } else if (error== "M" & trend== "A" & seasonality== "M"){
      classlabel[i] <- "ETS-trendseasonal"
    } else if (error== "M" & trend== "A" & seasonality== "N"){
      classlabel[i] <- "ETS-trend"
    }else if (error== "M" & trend== "Ad" & seasonality== "A"){
      classlabel[i] <- "ETS-dampedtrendseasonal"
    }else if (error== "M" & trend== "Ad" & seasonality== "M"){
      classlabel[i] <- "ETS-dampedtrendseasonal"
    }else if (error== "M" & trend== "Ad" & seasonality== "N"){
      classlabel[i] <- "ETS-dampedtrend"
    }else if (error== "M" & trend== "N" & seasonality== "A"){
      classlabel[i] <- "ETS-seasonal"
    }else if (error== "M" & trend== "N" & seasonality== "M"){
      classlabel[i] <- "ETS-seasonal"
    }else
      classlabel[i] <- "ETS-notrendnoseasonal"

  } else {
    classlabel[i] <- bestmethod[i]
  }
}
  return(classlabel)

}
#'@example
#'vect <- c(c("ARIMA(2,1,0) with drift", "ARIMA(2,0,0) with non-zero mean" ,"ARIMA(2,0,0) with non-zero mean" ,
#' "ARIMA(2,0,0) with non-zero mean" ,"ARIMA(0,0,1)", "ETS(A,A,A)", "rwd",
#' "ETS(A,N,N)"))
#' df_modnames <- split_names(vect)
#' classlabels <- classify_labels(df_modnames, vect)
#' classlabels

