#' split the names of ARIMA and ETS models
#'
#' split the names of ARIMA, ETS models to model name, different number of parameters
#' in each case.
#'
#' @param models vector of model names
#' @return a dataframe where columns gives the description of model components
#' @export
split_names <- function(models){

  ###Here we have choosen the separator as space(\\s), parenthesis ( \\( and \\) ) and commas (,)
  df <- data.frame(stringr::str_split_fixed(models,"\\s|\\(|\\)|,",n=5))
  #Rename basis the question, into follwing:
  #p is the number of autoregressive terms(AR)
  #d is the number of nonseasonal differences needed for stationarity(MA)
  #q is the number of lagged forecast errors in the prediction equation(order of differencing)
  names(df) <- c("Model","p","d","q","outcome")
  # If the outcome column contains all "" stop the code from here
  if(length(which(nchar(trimws(df$outcome))==0))==dim(df)[1]){
    df <- dplyr::select(df, c("Model", "p", "d", "q"))
    return(df)}

  #cleaning the outcome column by replacing spaces and dashes with underscores
  df$outcome_ <- gsub("\\s|-","_",trimws(df$outcome))
  #using model.matrix to calculate the dummies for drift and non zero mean,
  #for the value of 1 meaning True and 0 meaning False
  dummy_mat <- data.frame(model.matrix(~outcome_-1,data=df))
  df_final <- data.frame(df[,1:4],dummy_mat)
  df_final <- df_final[,c("Model", "p", "d", "q", "outcome_with_drift", "outcome_with_non_zero_mean")]
  return(df_final)
}
#' @example
#' library(seer)
#' vect_mod1 <- c("ARIMA(2,1,0)", "ARIMA(2,0,0)" )
#' split_names(vect_mod1)
#' @example
#' vect_mod2 <- c("ARIMA(2,1,0) with drift", "ARIMA(2,0,0) with non-zero mean" ,"ARIMA(2,0,0) with non-zero mean" ,
#' "ARIMA(2,0,0) with non-zero mean" ,"ARIMA(0,0,1)")
#' split_names(vect_mod2)
