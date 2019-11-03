#' Combination forecast based on fforms
#'
#' Compute combination forecast based on the vote matrix probabilities
#' @param fforms.ensemble a list output from fforms_ensemble function
#' @param tslist list of new time series
#' @param database whethe the time series is from mcom or other
#' @param h length of the forecast horizon
#' @return a list containing, point forecast, confidence interval, accuracy measure
#' @importFrom purrr map2
#' @author Thiyanga Talagala
#' @export
fforms_combinationforecast <- function(fforms.ensemble, tslist, database, h){

  ## tslist
  if (database == "other") {
    train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }
  ## fforms.ensemble, normalize the weights
  ensemble <- lapply(fforms.ensemble, function(temp){round(temp/sum(temp),2)})

  #accuracyFun <- match.fun(function_name)


Map(combination_forecast_inside, ensemble, train_test)


}
#'@example
#'fforms_votematrix <- matrix(c(0.1, 0.2, 0.7, 0.3, 0.3, 0.4), byrow=TRUE, ncol=3)
#'colnames(fforms_votematrix) <- c("wn", "rw", "rwd")
#'wmat <- fforms_ensemble(fforms_votematrix)
#'library(Mcomp)
#'data(M1)
#'m1y <- subset(M1, "yearly")
#'tslist <- m1y[1:2]
#'fforms_combinationforecast(wmat, tslist, database="M1", h=6)

